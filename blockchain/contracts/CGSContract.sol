// SPDX-License-Identifier: CC-BY-SA-4.0
pragma solidity >=0.5.0 <0.9.0;

/**
 * @title CGSContract
 * @dev Smart contract for managing initialization operations, loan applications, and guarantee payments
 * This contract implements a multi-authority attribute-based encryption system
 * combined with a loan application and guarantee payment workflow
 */
contract CGSContract {
    // ============================================================================
    // LOAN APPLICATION WORKFLOW FUNCTIONS
    // ============================================================================

    /**
     * @dev Initiates loan application by setting application form
     * This is the first step in the loan application workflow (status 0 -> 1)
     * @param _caseID The unique case identifier for this loan application
     * @param _hash1 First part of the application form document hash
     * @param _hash2 Second part of the application form document hash
     */
    function setApplicationForm(
        uint64 _caseID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        require(
            loanApplications[_caseID].status == 0,
            "Status must be 0 to set application form"
        );

        // Update status and store application form details
        loanApplications[_caseID].status = 1;
        loanApplications[_caseID].senderapplicationForm = msg.sender;
        loanApplications[_caseID].applicationFormDocument1 = _hash1;
        loanApplications[_caseID].applicationFormDocument2 = _hash2;
    }

    /**
     * @dev Retrieves application form details
     * @param _caseID The unique case identifier for this loan application
     * @return status Current status of the loan application
     * @return sender Address that submitted the application form
     * @return joined Concatenated bytes of the application form document hash
     */
    function getApplicationForm(
        uint64 _caseID
    ) public view returns (uint8, address, bytes memory) {
        uint8 status = loanApplications[_caseID].status;
        address sender = loanApplications[_caseID].senderapplicationForm;
        bytes32 p1 = loanApplications[_caseID].applicationFormDocument1;
        bytes32 p2 = loanApplications[_caseID].applicationFormDocument2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return (status, sender, joined);
    }

    /**
     * @dev Sets guarantee confirmation for loan application
     * This is the second step in the loan application workflow (status 1 -> 2)
     * @param _caseID The unique case identifier for this loan application
     * @param _hash1 First part of the guarantee confirmation document hash
     * @param _hash2 Second part of the guarantee confirmation document hash
     */
    function setGuaranteeConfirmation(
        uint64 _caseID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        require(
            loanApplications[_caseID].status == 1,
            "Status must be 1 to set guarantee confirmation"
        );

        // Update status and store guarantee confirmation details
        loanApplications[_caseID].status = 2;
        loanApplications[_caseID].senderguaranteeConfirmation = msg.sender;
        loanApplications[_caseID].guaranteeConfirmationDocument1 = _hash1;
        loanApplications[_caseID].guaranteeConfirmationDocument2 = _hash2;
    }

    /**
     * @dev Retrieves guarantee confirmation details
     * @param _caseID The unique case identifier for this loan application
     * @return status Current status of the loan application
     * @return sender Address that confirmed the guarantee
     * @return joined Concatenated bytes of the guarantee confirmation document hash
     */
    function getGuaranteeConfirmation(
        uint64 _caseID
    ) public view returns (uint8, address, bytes memory) {
        uint8 status = loanApplications[_caseID].status;
        address sender = loanApplications[_caseID].senderguaranteeConfirmation;
        bytes32 p1 = loanApplications[_caseID].guaranteeConfirmationDocument1;
        bytes32 p2 = loanApplications[_caseID].guaranteeConfirmationDocument2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return (status, sender, joined);
    }

    /**
     * @dev Finalizes loan application by setting loan request
     * This is the final step in the loan application workflow (status 2 -> 3)
     * @param _caseID The unique case identifier for this loan application
     * @param _hash1 First part of the loan request document hash
     * @param _hash2 Second part of the loan request document hash
     */
    function setLoanRequest(
        uint64 _caseID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        require(
            loanApplications[_caseID].status == 2,
            "Status must be 2 to set loan request"
        );

        // Complete the loan application workflow
        loanApplications[_caseID].status = 3;
        loanApplications[_caseID].senderloanRequest = msg.sender;
        loanApplications[_caseID].loanRequestDocument1 = _hash1;
        loanApplications[_caseID].loanRequestDocument2 = _hash2;
    }

    /**
     * @dev Retrieves loan request details
     * @param _caseID The unique case identifier for this loan application
     * @return status Current status of the loan application
     * @return sender Address that submitted the loan request
     * @return joined Concatenated bytes of the loan request document hash
     */
    function getLoanRequest(
        uint64 _caseID
    ) public view returns (uint8, address, bytes memory) {
        uint8 status = loanApplications[_caseID].status;
        address sender = loanApplications[_caseID].senderloanRequest;
        bytes32 p1 = loanApplications[_caseID].loanRequestDocument1;
        bytes32 p2 = loanApplications[_caseID].loanRequestDocument2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return (status, sender, joined);
    }

    // ============================================================================
    // GUARANTEE PAYMENT WORKFLOW FUNCTIONS
    // ============================================================================

    /**
     * @dev Initiates guarantee payment workflow by submitting a guarantee claim
     * This is the first step in the guarantee payment workflow (status 0 -> 1)
     * @param _caseID The unique case identifier for this guarantee payment
     * @param _hash1 First part of the guarantee claim document hash
     * @param _hash2 Second part of the guarantee claim document hash
     */
    function setGuaranteeClaim(
        uint64 _caseID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        require(
            guaranteePayments[_caseID].status == 0,
            "Status must be 0 to set guarantee claim"
        );

        // Update status and store guarantee claim details
        guaranteePayments[_caseID].status = 1;
        guaranteePayments[_caseID].sender = msg.sender;
        guaranteePayments[_caseID].guaranteeClaimDocument1 = _hash1;
        guaranteePayments[_caseID].guaranteeClaimDocument2 = _hash2;
    }

    /**
     * @dev Retrieves guarantee claim details
     * @param _caseID The unique case identifier for this guarantee payment
     * @return status Current status of the guarantee payment
     * @return sender Address that submitted the guarantee claim
     * @return joined Concatenated bytes of the guarantee claim document hash
     */
    function getGuaranteeClaim(
        uint64 _caseID
    ) public view returns (uint8, address, bytes memory) {
        uint8 status = guaranteePayments[_caseID].status;
        address sender = guaranteePayments[_caseID].sender;
        bytes32 p1 = guaranteePayments[_caseID].guaranteeClaimDocument1;
        bytes32 p2 = guaranteePayments[_caseID].guaranteeClaimDocument2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return (status, sender, joined);
    }

    /**
     * @dev Rejects guarantee payment request
     * This transitions from claim submitted to payment rejected (status 1 -> 4)
     * @param _caseID The unique case identifier for this guarantee payment
     * @param _hash1 First part of the payment rejection document hash
     * @param _hash2 Second part of the payment rejection document hash
     */
    function setRejectPayment(
        uint64 _caseID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        require(
            guaranteePayments[_caseID].status == 1,
            "Status must be 1 to reject payment"
        );

        // Update status to rejected and store rejection details
        guaranteePayments[_caseID].status = 4;
        guaranteePayments[_caseID].sender = msg.sender;
        guaranteePayments[_caseID].rejectPaymentDocument1 = _hash1;
        guaranteePayments[_caseID].rejectPaymentDocument2 = _hash2;
    }

    /**
     * @dev Retrieves payment rejection details
     * @param _caseID The unique case identifier for this guarantee payment
     * @return status Current status of the guarantee payment
     * @return sender Address that rejected the payment
     * @return joined Concatenated bytes of the payment rejection document hash
     * @notice There's a bug in the original code - second hash part uses Document1 instead of Document2
     */
    function getRejectPayment(
        uint64 _caseID
    ) public view returns (uint8, address, bytes memory) {
        uint8 status = guaranteePayments[_caseID].status;
        address sender = guaranteePayments[_caseID].sender;
        bytes32 p1 = guaranteePayments[_caseID].rejectPaymentDocument1;
        bytes32 p2 = guaranteePayments[_caseID].rejectPaymentDocument2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return (status, sender, joined);
    }

    /**
     * @dev Approves guarantee payment request
     * This transitions from claim submitted to payment allowed (status 1 -> 2)
     * @param _caseID The unique case identifier for this guarantee payment
     * @param _hash1 First part of the payment approval document hash
     * @param _hash2 Second part of the payment approval document hash
     */
    function setAllowPayment(
        uint64 _caseID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        require(
            guaranteePayments[_caseID].status == 1,
            "Status must be 1 to allow payment"
        );

        // Update status to allowed and store approval details
        guaranteePayments[_caseID].status = 2;
        guaranteePayments[_caseID].sender = msg.sender;
        guaranteePayments[_caseID].allowPaymentDocument1 = _hash1;
        guaranteePayments[_caseID].allowPaymentDocument2 = _hash2;
    }

    /**
     * @dev Retrieves payment approval details
     * @param _caseID The unique case identifier for this guarantee payment
     * @return status Current status of the guarantee payment
     * @return sender Address that approved the payment
     * @return joined Concatenated bytes of the payment approval document hash
     */
    function getAllowPayment(
        uint64 _caseID
    ) public view returns (uint8, address, bytes memory) {
        uint8 status = guaranteePayments[_caseID].status;
        address sender = guaranteePayments[_caseID].sender;
        bytes32 p1 = guaranteePayments[_caseID].allowPaymentDocument1;
        bytes32 p2 = guaranteePayments[_caseID].allowPaymentDocument2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return (status, sender, joined);
    }

    /**
     * @dev Finalizes guarantee payment by allowing guarantor to claim
     * This is the final step in the guarantee payment workflow (status 2 -> 3)
     * @param _caseID The unique case identifier for this guarantee payment
     * @param _hash1 First part of the guarantor claim document hash
     * @param _hash2 Second part of the guarantor claim document hash
     */
    function setGuaranteeClaimGuarantor(
        uint64 _caseID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        require(
            guaranteePayments[_caseID].status == 2,
            "Status must be 2 to set guarantor claim"
        );

        // Complete the guarantee payment workflow
        guaranteePayments[_caseID].status = 3;
        guaranteePayments[_caseID].sender = msg.sender;
        guaranteePayments[_caseID].guaranteeClaimGuarantorDocument1 = _hash1;
        guaranteePayments[_caseID].guaranteeClaimGuarantorDocument2 = _hash2;
    }

    /**
     * @dev Retrieves guarantor claim details
     * @param _caseID The unique case identifier for this guarantee payment
     * @return status Current status of the guarantee payment
     * @return sender Address that submitted the guarantor claim
     * @return joined Concatenated bytes of the guarantor claim document hash
     */
    function getGuaranteeClaimGuarantor(
        uint64 _caseID
    ) public view returns (uint8, address, bytes memory) {
        uint8 status = guaranteePayments[_caseID].status;
        address sender = guaranteePayments[_caseID].sender;
        bytes32 p1 = guaranteePayments[_caseID]
            .guaranteeClaimGuarantorDocument1;
        bytes32 p2 = guaranteePayments[_caseID]
            .guaranteeClaimGuarantorDocument2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return (status, sender, joined);
    }

    // ============================================================================
    // DATA STRUCTURES
    // ============================================================================

    /**
     * @dev Structure to store authority metadata as two 32-byte hash parts
     * Used for identifying and storing authority information
     */
    struct authoritiesNames {
        bytes32 hashPart1;
        bytes32 hashPart2;
    }
    // Mapping to store authority names for each instance ID and address
    mapping(uint64 => mapping(address => authoritiesNames)) authoritiesName;

    /**
     * @dev Structure to store hashed first commitment element
     * Used in multi-authority attribute-based encryption authority initialization
     */
    struct firstElementHashed {
        bytes32 hashPart1;
        bytes32 hashPart2;
    }
    // Mapping to store first hashed element for each instance and authority
    mapping(uint64 => mapping(address => firstElementHashed)) firstGHashed;

    /**
     * @dev Structure to store hashed second commitment element
     * Used in multi-authority attribute-based encryption authority initialization
     */
    struct secondElementHashed {
        bytes32 hashPart1;
        bytes32 hashPart2;
    }
    // Mapping to store second hashed element for each instance and authority
    mapping(uint64 => mapping(address => secondElementHashed)) secondGHashed;

    /**
     * @dev Structure to store first element in clear that has to match the commitment
     */
    struct firstElement {
        bytes32 hashPart1;
        bytes32 hashPart2;
        bytes32 hashPart3;
    }
    // Mapping to store first element for each instance and authority
    mapping(uint64 => mapping(address => firstElement)) firstG;

    /**
     * @dev Structure to store second element in clear that has to match the commitment
     */
    struct secondElement {
        bytes32 hashPart1;
        bytes32 hashPart2;
        bytes32 hashPart3;
    }
    // Mapping to store second element for each instance and authority
    mapping(uint64 => mapping(address => secondElement)) secondG;

    /**
     * @dev Structure to store public parameters of authorities
     * Used for cryptographic public parameter storage
     */
    struct publicParameters {
        bytes32 hashPart1;
        bytes32 hashPart2;
    }
    // Mapping to store public parameters for each instance and authority
    mapping(uint64 => mapping(address => publicParameters)) parameters;

    /**
     * @dev Structure to store authorities' public keys
     * Used for cryptographic public key storage
     */
    struct publicKey {
        bytes32 hashPart1;
        bytes32 hashPart2;
    }
    // Mapping to store public keys for each instance and authority
    mapping(uint64 => mapping(address => publicKey)) publicKeys;

    /**
     * @dev Structure to store reader public keys
     * Used for storing public keys of data readers
     */
    struct publicKeyReaders {
        bytes32 hashPart1;
        bytes32 hashPart2;
    }
    // Mapping to store reader public keys by address
    mapping(address => publicKeyReaders) publicKeysReaders;

    /**
     * @dev Structure to store user metadata
     * Used for storing user attribute information
     */
    struct userAttributes {
        bytes32 hashPart1;
        bytes32 hashPart2;
    }
    // Mapping to store user attributes by instance ID
    mapping(uint64 => userAttributes) allUsers;

    // ============================================================================
    // LOAN APPLICATION DATA STRUCTURES
    // ============================================================================

    /**
     * @dev Structure to manage loan application workflow
     * Tracks the complete loan application process with status and documents
     * Status values: 0=initial, 1=application_form_set, 2=guarantee_confirmed, 3=loan_requested
     */
    struct loanApplication {
        uint8 status; // Current workflow status
        address senderapplicationForm; // Address that submitted application form
        address senderguaranteeConfirmation; // Address that confirmed guarantee
        address senderloanRequest; // Address that submitted loan request
        bytes32 applicationFormDocument1; // First part of application form document hash
        bytes32 applicationFormDocument2; // Second part of application form document hash
        bytes32 guaranteeConfirmationDocument1; // First part of guarantee confirmation hash
        bytes32 guaranteeConfirmationDocument2; // Second part of guarantee confirmation hash
        bytes32 loanRequestDocument1; // First part of loan request document hash
        bytes32 loanRequestDocument2; // Second part of loan request document hash
    }
    // Mapping to store loan applications by case ID
    mapping(uint64 => loanApplication) loanApplications;

    /**
     * @dev Structure to manage guarantee payment workflow
     * Tracks the guarantee claim and payment approval process
     * Status values: 0=initial, 1=claim_submitted, 2=payment_allowed, 3=guarantor_claimed, 4=payment_rejected
     */
    struct guaranteePayment {
        uint8 status; // Current workflow status
        address sender; // Address of the last action sender
        bytes32 guaranteeClaimDocument1; // First part of guarantee claim document hash
        bytes32 guaranteeClaimDocument2; // Second part of guarantee claim document hash
        bytes32 rejectPaymentDocument1; // First part of payment rejection document hash
        bytes32 rejectPaymentDocument2; // Second part of payment rejection document hash
        bytes32 allowPaymentDocument1; // First part of payment approval document hash
        bytes32 allowPaymentDocument2; // Second part of payment approval document hash
        bytes32 guaranteeClaimGuarantorDocument1; // First part of guarantor claim document hash
        bytes32 guaranteeClaimGuarantorDocument2; // Second part of guarantor claim document hash
    }
    // Mapping to store guarantee payments by case ID
    mapping(uint64 => guaranteePayment) guaranteePayments;

    // ============================================================================
    // AUTHORITY INITIALIZATION AND EXECUTION FUNCTIONS
    // ============================================================================

    /**
     * @dev Sets authorities metadata for a specific instance
     * @param _instanceID The instance identifier
     * @param _hash1 First part of the authority ipfs file hash
     * @param _hash2 Second part of the authority ipfs file hash
     */

    function setAuthoritiesNames(
        uint64 _instanceID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        // Store the authority name as two separate hash parts
        authoritiesName[_instanceID][msg.sender].hashPart1 = _hash1;
        authoritiesName[_instanceID][msg.sender].hashPart2 = _hash2;
    }

    /**
     * @dev Retrieves authority names for a specific address and instance
     * @param _address The address of the authority
     * @param _instanceID The instance identifier
     * @return joined The concatenated bytes of the authority name hash parts
     */
    function getAuthoritiesNames(
        address _address,
        uint64 _instanceID
    ) public view returns (bytes memory) {
        // Get the two hash parts
        bytes32 p1 = authoritiesName[_instanceID][_address].hashPart1;
        bytes32 p2 = authoritiesName[_instanceID][_address].hashPart2;

        // Create a 64-byte array to hold the concatenated hash
        bytes memory joined = new bytes(64);

        // Use assembly to efficiently copy the hash parts
        assembly {
            mstore(add(joined, 32), p1) // Store first part at offset 32
            mstore(add(joined, 64), p2) // Store second part at offset 64
        }
        return joined;
    }

    /**
     * @dev Sets hashed cryptographic elements for an instance
     * @param _instanceID The instance identifier
     * @param _hash1 First part of the first hashed element
     * @param _hash2 Second part of the first hashed element
     * @param _hash3 First part of the second hashed element
     * @param _hash4 Second part of the second hashed element
     */
    function setElementHashed(
        uint64 _instanceID,
        bytes32 _hash1,
        bytes32 _hash2,
        bytes32 _hash3,
        bytes32 _hash4
    ) public {
        // Store first hashed element
        firstGHashed[_instanceID][msg.sender].hashPart1 = _hash1;
        firstGHashed[_instanceID][msg.sender].hashPart2 = _hash2;

        // Store second hashed element
        secondGHashed[_instanceID][msg.sender].hashPart1 = _hash3;
        secondGHashed[_instanceID][msg.sender].hashPart2 = _hash4;
    }

    /**
     * @dev Retrieves hashed cryptographic elements for an address and instance
     * @param _address The address of the authority
     * @param _instanceID The instance identifier
     * @return Two concatenated bytes arrays representing the first and second hashed elements
     */
    function getElementHashed(
        address _address,
        uint64 _instanceID
    ) public view returns (bytes memory, bytes memory) {
        // Get hash parts for both elements
        bytes32 p1 = firstGHashed[_instanceID][_address].hashPart1;
        bytes32 p2 = firstGHashed[_instanceID][_address].hashPart2;
        bytes32 p3 = secondGHashed[_instanceID][_address].hashPart1;
        bytes32 p4 = secondGHashed[_instanceID][_address].hashPart2;

        // Build first element bytes
        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }

        // Build second element bytes
        bytes memory joinedsec = new bytes(64);
        assembly {
            mstore(add(joinedsec, 32), p3)
            mstore(add(joinedsec, 64), p4)
        }
        return (joined, joinedsec);
    }

    /**
     * @dev Sets in clear full cryptographic elements (3 parts each) for an instance
     * @param _instanceID The instance identifier
     * @param _hash1 First part of the first element
     * @param _hash2 Second part of the first element
     * @param _hash3 Third part of the first element
     * @param _hash4 First part of the second element
     * @param _hash5 Second part of the second element
     * @param _hash6 Third part of the second element
     */
    function setElement(
        uint64 _instanceID,
        bytes32 _hash1,
        bytes32 _hash2,
        bytes32 _hash3,
        bytes32 _hash4,
        bytes32 _hash5,
        bytes32 _hash6
    ) public {
        // Store first element (3 parts)
        firstG[_instanceID][msg.sender].hashPart1 = _hash1;
        firstG[_instanceID][msg.sender].hashPart2 = _hash2;
        firstG[_instanceID][msg.sender].hashPart3 = _hash3;

        // Store second element (3 parts)
        secondG[_instanceID][msg.sender].hashPart1 = _hash4;
        secondG[_instanceID][msg.sender].hashPart2 = _hash5;
        secondG[_instanceID][msg.sender].hashPart3 = _hash6;
    }

    /**
     * @dev Retrieves in clear full cryptographic elements for an address and instance
     * @param _address The address of the authority
     * @param _instanceID The instance identifier
     * @return Four values: first element concatenated bytes, third part of first element,
     *         second element concatenated bytes, third part of second element
     */
    function getElement(
        address _address,
        uint64 _instanceID
    ) public view returns (bytes memory, bytes32, bytes memory, bytes32) {
        // Get all hash parts
        bytes32 p1 = firstG[_instanceID][_address].hashPart1;
        bytes32 p2 = firstG[_instanceID][_address].hashPart2;
        bytes32 p3 = firstG[_instanceID][_address].hashPart3;
        bytes32 p4 = secondG[_instanceID][_address].hashPart1;
        bytes32 p5 = secondG[_instanceID][_address].hashPart2;
        bytes32 p6 = secondG[_instanceID][_address].hashPart3;

        // Build first element bytes (first two parts concatenated)
        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }

        // Build second element bytes (first two parts concatenated)
        bytes memory joinedsec = new bytes(64);
        assembly {
            mstore(add(joinedsec, 32), p4)
            mstore(add(joinedsec, 64), p5)
        }

        return (joined, p3, joinedsec, p6);
    }

    /**
     * @dev Sets public parameters for an instance
     * @param _instanceID The instance identifier
     * @param _hash1 First part of the public parameters hash
     * @param _hash2 Second part of the public parameters hash
     */
    function setPublicParameters(
        uint64 _instanceID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        parameters[_instanceID][msg.sender].hashPart1 = _hash1;
        parameters[_instanceID][msg.sender].hashPart2 = _hash2;
    }

    /**
     * @dev Retrieves public parameters for an address and instance
     * @param _address The address of the authority
     * @param _instanceID The instance identifier
     * @return joined The concatenated bytes of the public parameters hash parts
     */
    function getPublicParameters(
        address _address,
        uint64 _instanceID
    ) public view returns (bytes memory) {
        bytes32 p1 = parameters[_instanceID][_address].hashPart1;
        bytes32 p2 = parameters[_instanceID][_address].hashPart2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return joined;
    }

    /**
     * @dev Sets authorities' public keys for an instance
     * @param _instanceID The instance identifier
     * @param _hash1 First part of the public key hash
     * @param _hash2 Second part of the public key hash
     */
    function setPublicKey(
        uint64 _instanceID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        publicKeys[_instanceID][msg.sender].hashPart1 = _hash1;
        publicKeys[_instanceID][msg.sender].hashPart2 = _hash2;
    }

    /**
     * @dev Retrieves authorities' public keys for an instance
     * @param _address The address of the authority
     * @param _instanceID The instance identifier
     * @return joined The concatenated bytes of the public key hash parts
     */
    function getPublicKey(
        address _address,
        uint64 _instanceID
    ) public view returns (bytes memory) {
        bytes32 p2 = publicKeys[_instanceID][_address].hashPart1;
        bytes32 p3 = publicKeys[_instanceID][_address].hashPart2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p2)
            mstore(add(joined, 64), p3)
        }
        return (joined);
    }

    /**
     * @dev Sets public key for readers (users who can encrypt and decrypt data)
     * @param _hash1 First part of the reader public key hash
     * @param _hash2 Second part of the reader public key hash
     */
    function setPublicKeyReaders(bytes32 _hash1, bytes32 _hash2) public {
        publicKeysReaders[msg.sender].hashPart1 = _hash1;
        publicKeysReaders[msg.sender].hashPart2 = _hash2;
    }

    /**
     * @dev Retrieves public key for a reader
     * @param _address The address of the reader
     * @return joined The concatenated bytes of the reader's public key hash parts
     */
    function getPublicKeyReaders(
        address _address
    ) public view returns (bytes memory) {
        bytes32 p2 = publicKeysReaders[_address].hashPart1;
        bytes32 p3 = publicKeysReaders[_address].hashPart2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p2)
            mstore(add(joined, 64), p3)
        }
        return (joined);
    }

    /**
     * @dev Sets user attributes for cryptographic operations
     * @param _instanceID The instance identifier
     * @param _hash1 First part of the user attributes hash
     * @param _hash2 Second part of the user attributes hash
     */
    function setUserAttributes(
        uint64 _instanceID,
        bytes32 _hash1,
        bytes32 _hash2
    ) public {
        allUsers[_instanceID].hashPart1 = _hash1;
        allUsers[_instanceID].hashPart2 = _hash2;
    }

    /**
     * @dev Retrieves user attributes for an instance
     * @param _instanceID The instance identifier
     * @return joined The concatenated bytes of the user attributes hash parts
     */
    function getUserAttributes(
        uint64 _instanceID
    ) public view returns (bytes memory) {
        bytes32 p1 = allUsers[_instanceID].hashPart1;
        bytes32 p2 = allUsers[_instanceID].hashPart2;

        bytes memory joined = new bytes(64);
        assembly {
            mstore(add(joined, 32), p1)
            mstore(add(joined, 64), p2)
        }
        return joined;
    }
}
