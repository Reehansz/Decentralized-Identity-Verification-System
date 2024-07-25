// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityVerification {
    // Define roles for access control
    enum Role { NormalUser, Verifier, Organization }
    
    // Mapping to store roles by Ethereum address
    mapping(address => Role) public roles;

    // Mapping to convert Role enum to string
    mapping(Role => string) public roleToString;

    // Struct to represent an identity
    // Struct to represent an identity
    struct Identity {
        string name;
        string dob;
        bytes32 idDocumentHash;
        bool verified;
        mapping(address => bool) accessRequests; // Mapping to track access requests
        mapping(address => bool) accessGranted;  // Mapping to track access granted
    }

    
    // Mapping to store identities by Ethereum address
    mapping(address => Identity) public identities;

    // Events for identity registration and verification
    event IdentityRegistered(address indexed user, string name, string dob, bytes32 idDocumentHash);
    event IdentityVerified(address indexed verifier, address indexed user);
    event AccessRequested(address indexed requester, address indexed user);
    event AccessGranted(address indexed user, address indexed requester);
    
    // Modifier to restrict access to verifiers only
    modifier onlyVerifier() {
        require(roles[msg.sender] == Role.Verifier, "Only verifiers can call this function");
        _;
    }

    // Modifier to restrict access to organizations or user only
    modifier onlyOrganizationOrUser(address _user) {
        require(roles[msg.sender] == Role.Organization || msg.sender == _user || roles[msg.sender] == Role.NormalUser, "Only organizations or user can call this function");
        _;
    }

    // Constructor to initialize roleToString mapping
    constructor() {
        roleToString[Role.NormalUser] = "Normal User";
        roleToString[Role.Verifier] = "Verifier";
        roleToString[Role.Organization] = "Organization";
    }

    // Function to register an identity
    function registerIdentity(string memory _name, string memory _dob, bytes32 _idDocumentHash) public {
    require(bytes(identities[msg.sender].name).length == 0, "Identity already registered");
    Identity storage newIdentity = identities[msg.sender];
    newIdentity.name = _name;
    newIdentity.dob = _dob;
    newIdentity.idDocumentHash = _idDocumentHash;
    newIdentity.verified = false;
    emit IdentityRegistered(msg.sender, _name, _dob, _idDocumentHash);
}


    // Function to verify an identity
    function verifyIdentity(address _user) public onlyVerifier {
        identities[_user].verified = true;
        emit IdentityVerified(msg.sender, _user);
    }

    // Function to request access to user's identity
    function requestAccess(address _user) public onlyOrganizationOrUser(_user) {
        identities[_user].accessRequests[msg.sender] = true;
        emit AccessRequested(msg.sender, _user);
    }

    // Function for user to grant access to their identity
    // Function for user to grant access to their identity
    function grantAccess(address _requester) public {
        require(identities[msg.sender].accessRequests[_requester], "No access request found");
        identities[msg.sender].accessGranted[_requester] = true; // Update accessGranted mapping
        delete identities[msg.sender].accessRequests[_requester];
        emit AccessGranted(msg.sender, _requester);
    }


    // Function to retrieve identity details
    function getIdentity(address _user) public view onlyOrganizationOrUser(_user) returns (string memory, string memory, bytes32, bool) {
    // Check if the caller is the user or if the organization has been granted access
        require(msg.sender == _user || identities[_user].accessGranted[msg.sender], "Access not granted");

        return (
            identities[_user].name,
            identities[_user].dob,
            identities[_user].idDocumentHash,
            identities[_user].verified
        );
    }

    // Function to set role for an address
    function setRole(address _address, Role _role) public {
        // Add access control logic here to restrict who can set roles
        roles[_address] = _role;
    }

    // Function to get role for an address
    function getRole(address _address) public view returns (string memory) {
        return roleToString[roles[_address]];
    }

    // Fallback function to receive ether
    receive() external payable {}

    // Fallback function to receive non-ether transactions
    fallback() external payable {}
}
