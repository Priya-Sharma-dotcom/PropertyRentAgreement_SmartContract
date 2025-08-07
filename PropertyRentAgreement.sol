//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RentAgree {
    address public owner;
    uint public agreementCounter = 0;
    bool private locked;

    constructor() {
        owner = msg.sender;
    }

    struct Agreement {
        uint rent;
        string location;
        uint leaseStartDate;
        uint leaseEndDate;
        uint security;
        bool isSecurityPaid;
        address tenant;
    }

    mapping(uint => Agreement) public agreements;

    event AgreementCreated(uint propertyId, address owner, address tenant);
    event RentPaid(uint id, address tenant, address owner, uint rent, uint timestamp);
    event LeaseTerminated(uint propertyId, address owner, address tenant, uint timestamp);
    event AgreementUpdated(uint id, uint newRent, string newLocation);

    modifier OnlyOwner() {
        require(msg.sender == owner, "Only property owner can call this function");
        _;
    }

    modifier OnlyTenant(uint id) {
        require(msg.sender == agreements[id].tenant, "Not tenant");
        _;
    }

    modifier noReentrant() {
        require(!locked, "Reentrancy not allowed");
        locked = true;
        _;
        locked = false;
    }

    function createRentalAgreement(
        uint _rent,
        string memory _location,
        uint _leaseStartDate,
        uint _leaseEndDate,
        uint _security,
        address _tenant
    ) public OnlyOwner {
        require(_tenant != address(0), "Tenant address is invalid");
        require(_tenant != owner, "Owner cannot be tenant");
        require(_leaseEndDate > _leaseStartDate, "Lease end must be after start");

        agreementCounter++;
        agreements[agreementCounter] = Agreement({
            rent: _rent,
            location: _location,
            leaseStartDate: _leaseStartDate,
            leaseEndDate: _leaseEndDate,
            security: _security,
            isSecurityPaid: false,
            tenant: _tenant
        });

        emit AgreementCreated(agreementCounter, owner, _tenant);
    }

    function updateRentAgreement(
        uint id,
        uint _newRent,
        string memory _newLocation
    ) public OnlyOwner {
        Agreement storage agreement = agreements[id];
        require(block.timestamp < agreement.leaseStartDate, "Cannot update after lease starts");

        agreement.rent = _newRent;
        agreement.location = _newLocation;

        emit AgreementUpdated(id, _newRent, _newLocation);
    }

    function payRent(uint id) public payable OnlyTenant(id) noReentrant {
        Agreement storage agreement = agreements[id];

        require(block.timestamp >= agreement.leaseStartDate, "Lease has not started yet");
        require(block.timestamp <= agreement.leaseEndDate, "Lease has ended");

        uint totalRent = agreement.rent;
        if (!agreement.isSecurityPaid) {
            totalRent += agreement.security;
            agreement.isSecurityPaid = true;
        }

        require(msg.value == totalRent, "Incorrect rent amount");

        payable(owner).transfer(msg.value);

        emit RentPaid(id, agreement.tenant, owner, agreement.rent, block.timestamp);
    }

    function terminateLeaseAndRefundDeposit(uint id) public OnlyOwner noReentrant {
        Agreement storage agreement = agreements[id];

        require(block.timestamp >= agreement.leaseEndDate, "Lease has not ended yet");
        require(agreement.isSecurityPaid, "Security not paid");

        payable(agreement.tenant).transfer(agreement.security);

        emit LeaseTerminated(id, owner, agreement.tenant, block.timestamp);

        delete agreements[id]; 
    }

    function getAgreementDetails(uint id) public view returns (Agreement memory) {
        return agreements[id];
    }

    fallback() external payable {
        revert("Fallback not allowed");
    }

    receive() external payable {
        revert("Ether not accepted directly");
    }
}

