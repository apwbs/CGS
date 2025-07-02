// SPDX-License-Identifier: CC-BY-SA-4.0
pragma solidity >= 0.5.0 < 0.9.0;

contract MARTSIAEth {

  struct authoritiesNames {
    bytes32 hashPart1;
    bytes32 hashPart2;
  }
  mapping (uint64 => mapping (address => authoritiesNames)) authoritiesName;

  struct firstElementHashed {
    bytes32 hashPart1;
    bytes32 hashPart2;
  }
  mapping (uint64 => mapping (address => firstElementHashed)) firstGHashed;

  struct secondElementHashed {
    bytes32 hashPart1;
    bytes32 hashPart2;
  }
  mapping (uint64 => mapping (address => secondElementHashed)) secondGHashed;

  struct firstElement {
    bytes32 hashPart1;
    bytes32 hashPart2;
    bytes32 hashPart3;
  }
  mapping (uint64 => mapping (address => firstElement)) firstG;

  struct secondElement {
    bytes32 hashPart1;
    bytes32 hashPart2;
    bytes32 hashPart3;
  }
  mapping (uint64 => mapping (address => secondElement)) secondG;

  struct publicParameters {
    bytes32 hashPart1;
    bytes32 hashPart2;
  }
  mapping (uint64 => mapping (address => publicParameters)) parameters;

  struct publicKey {
    bytes32 hashPart1;
    bytes32 hashPart2;
  }
  mapping (uint64 => mapping (address =>  publicKey)) publicKeys;

  struct publicKeyReaders {
    bytes32 hashPart1;
    bytes32 hashPart2;
  }
  mapping (address =>  publicKeyReaders) publicKeysReaders;

  struct IPFSCiphertext {
    address sender;
    bytes32 hashPart1;
    bytes32 hashPart2;
  }
  mapping (uint64 => IPFSCiphertext) allLinks;

  struct userAttributes {
    bytes32 hashPart1;
    bytes32 hashPart2;
  }
  mapping (uint64 => userAttributes) allUsers;

  struct loanApplication {
    uint8 status;
    address senderapplicationForm;
    address senderguaranteeConfirmation;
    address senderloanRequest;
    bytes32 applicationFormDocument1;
    bytes32 applicationFormDocument2;
    bytes32 guaranteeConfirmationDocument1;
    bytes32 guaranteeConfirmationDocument2;
    bytes32 loanRequestDocument1;
    bytes32 loanRequestDocument2;
  }
  mapping (uint64 => loanApplication) loanApplications;

  struct guaranteePayment {
    uint8 status;
    address sender;
    bytes32 guaranteeClaimDocument1;
    bytes32 guaranteeClaimDocument2;
    bytes32 rejectPaymentDocument1;
    bytes32 rejectPaymentDocument2;
    bytes32 allowPaymentDocument1;
    bytes32 allowPaymentDocument2;
    bytes32 guaranteeClaimGuarantorDocument1;
    bytes32 guaranteeClaimGuarantorDocument2;
  }
  mapping (uint64 => guaranteePayment) guaranteePayments;

  function setAuthoritiesNames(uint64 _instanceID, bytes32 _hash1, bytes32 _hash2) public {
    authoritiesName[_instanceID][msg.sender].hashPart1 = _hash1;
    authoritiesName[_instanceID][msg.sender].hashPart2 = _hash2;
  }

  function getAuthoritiesNames(address _address, uint64 _instanceID) public view returns (bytes memory) {
    bytes32 p1 = authoritiesName[_instanceID][_address].hashPart1;
    bytes32 p2 = authoritiesName[_instanceID][_address].hashPart2;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p1)
      mstore(add(joined, 64), p2)
    }
    return joined;
  }

  function setElementHashed(uint64 _instanceID, bytes32 _hash1, bytes32 _hash2, bytes32 _hash3, bytes32 _hash4) public {
    firstGHashed[_instanceID][msg.sender].hashPart1 = _hash1;
    firstGHashed[_instanceID][msg.sender].hashPart2 = _hash2;
    secondGHashed[_instanceID][msg.sender].hashPart1 = _hash3;
    secondGHashed[_instanceID][msg.sender].hashPart2 = _hash4;
  }

  function getElementHashed(address _address, uint64 _instanceID) public view returns (bytes memory, bytes memory) {
    bytes32 p1 = firstGHashed[_instanceID][_address].hashPart1;
    bytes32 p2 = firstGHashed[_instanceID][_address].hashPart2;
    bytes32 p3 = secondGHashed[_instanceID][_address].hashPart1;
    bytes32 p4 = secondGHashed[_instanceID][_address].hashPart2;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p1)
      mstore(add(joined, 64), p2)
    }
    bytes memory joinedsec = new bytes(64);
    assembly {
      mstore(add(joinedsec, 32), p3)
      mstore(add(joinedsec, 64), p4)
    }
    return (joined, joinedsec);
  }

  function setElement(uint64 _instanceID, bytes32 _hash1, bytes32 _hash2, bytes32 _hash3, bytes32 _hash4, bytes32 _hash5, bytes32 _hash6) public {
    firstG[_instanceID][msg.sender].hashPart1 = _hash1;
    firstG[_instanceID][msg.sender].hashPart2 = _hash2;
    firstG[_instanceID][msg.sender].hashPart3 = _hash3;
    secondG[_instanceID][msg.sender].hashPart1 = _hash4;
    secondG[_instanceID][msg.sender].hashPart2 = _hash5;
    secondG[_instanceID][msg.sender].hashPart3 = _hash6;
  }

  function getElement(address _address, uint64 _instanceID) public view returns (bytes memory, bytes32, bytes memory, bytes32) {
    bytes32 p1 = firstG[_instanceID][_address].hashPart1;
    bytes32 p2 = firstG[_instanceID][_address].hashPart2;
    bytes32 p3 = firstG[_instanceID][_address].hashPart3;
    bytes32 p4 = secondG[_instanceID][_address].hashPart1;
    bytes32 p5 = secondG[_instanceID][_address].hashPart2;
    bytes32 p6 = secondG[_instanceID][_address].hashPart3;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p1)
      mstore(add(joined, 64), p2)
    }
    bytes memory joinedsec = new bytes(64);
    assembly {
      mstore(add(joinedsec, 32), p4)
      mstore(add(joinedsec, 64), p5)
    }

    return (joined, p3, joinedsec, p6);
  }

  function setPublicParameters(uint64 _instanceID, bytes32 _hash1, bytes32 _hash2) public {
    parameters[_instanceID][msg.sender].hashPart1 = _hash1;
    parameters[_instanceID][msg.sender].hashPart2 = _hash2;
  }

  function getPublicParameters(address _address, uint64 _instanceID) public view returns (bytes memory) {
    bytes32 p1 = parameters[_instanceID][_address].hashPart1;
    bytes32 p2 = parameters[_instanceID][_address].hashPart2;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p1)
      mstore(add(joined, 64), p2)
    }
    return joined;
  }

  function setPublicKey(uint64 _instanceID, bytes32 _hash1, bytes32 _hash2) public {
    publicKeys[_instanceID][msg.sender].hashPart1 = _hash1;
    publicKeys[_instanceID][msg.sender].hashPart2 = _hash2;
  }

  function getPublicKey(address _address, uint64 _instanceID) public view returns (bytes memory) {
    bytes32 p2 = publicKeys[_instanceID][_address].hashPart1;
    bytes32 p3 = publicKeys[_instanceID][_address].hashPart2;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p2)
      mstore(add(joined, 64), p3)
    }
      return (joined);
  }

  function setPublicKeyReaders(bytes32 _hash1, bytes32 _hash2) public {
    publicKeysReaders[msg.sender].hashPart1 = _hash1;
    publicKeysReaders[msg.sender].hashPart2 = _hash2;
  }

  function getPublicKeyReaders(address _address) public view returns (bytes memory) {
    bytes32 p2 = publicKeysReaders[_address].hashPart1;
    bytes32 p3 = publicKeysReaders[_address].hashPart2;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p2)
      mstore(add(joined, 64), p3)
    }
      return (joined);
  }

  function setIPFSLink(uint64 _messageID, bytes32 _hash1, bytes32 _hash2) public {
    allLinks[_messageID].sender = msg.sender;
    allLinks[_messageID].hashPart1 = _hash1;
    allLinks[_messageID].hashPart2 = _hash2;
  }

  function getIPFSLink(uint64 _messageID) public view returns (address, bytes memory) {
    address sender = allLinks[_messageID].sender;
    bytes32 p1 = allLinks[_messageID].hashPart1;
    bytes32 p2 = allLinks[_messageID].hashPart2;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p1)
      mstore(add(joined, 64), p2)
    }
    return (sender, joined);
  }

  function setUserAttributes(uint64 _instanceID, bytes32 _hash1, bytes32 _hash2) public {
    allUsers[_instanceID].hashPart1 = _hash1;
    allUsers[_instanceID].hashPart2 = _hash2;
  }

  function getUserAttributes(uint64 _instanceID) public view returns (bytes memory) {
    bytes32 p1 = allUsers[_instanceID].hashPart1;
    bytes32 p2 = allUsers[_instanceID].hashPart2;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p1)
      mstore(add(joined, 64), p2)
    }
    return joined;
  }










  function setApplicationForm(uint64 _caseID, bytes32 _hash1, bytes32 _hash2) public {
    require(loanApplications[_caseID].status == 0, "Status must be 0 to set application form");

    loanApplications[_caseID].status = 1;
    loanApplications[_caseID].senderapplicationForm = msg.sender;
    loanApplications[_caseID].applicationFormDocument1 = _hash1;
    loanApplications[_caseID].applicationFormDocument2 = _hash2;
  }

  function getApplicationForm(uint64 _caseID) public view returns (uint8, address, bytes memory) {
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


  function setGuaranteeConfirmation(uint64 _caseID, bytes32 _hash1, bytes32 _hash2) public {
    require(loanApplications[_caseID].status == 1, "Status must be 1 to set guarantee confirmation");

    loanApplications[_caseID].status = 2;
    loanApplications[_caseID].senderguaranteeConfirmation = msg.sender;
    loanApplications[_caseID].guaranteeConfirmationDocument1 = _hash1;
    loanApplications[_caseID].guaranteeConfirmationDocument2 = _hash2;
  }

  function getGuaranteeConfirmation(uint64 _caseID) public view returns (uint8, address, bytes memory) {
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


  function setLoanRequest(uint64 _caseID, bytes32 _hash1, bytes32 _hash2) public {
      require(loanApplications[_caseID].status == 2, "Status must be 2 to set loan request");

      loanApplications[_caseID].status = 3;
      loanApplications[_caseID].senderloanRequest = msg.sender;
      loanApplications[_caseID].loanRequestDocument1 = _hash1;
      loanApplications[_caseID].loanRequestDocument2 = _hash2;
  }

  function getLoanRequest(uint64 _caseID) public view returns (uint8, address, bytes memory) {
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










  function setGuaranteeClaim(uint64 _caseID, bytes32 _hash1, bytes32 _hash2) public {
    require(guaranteePayments[_caseID].status == 0, "Status must be 0 to set guarantee claim");

    guaranteePayments[_caseID].status = 1;
    guaranteePayments[_caseID].sender = msg.sender;
    guaranteePayments[_caseID].guaranteeClaimDocument1 = _hash1;
    guaranteePayments[_caseID].guaranteeClaimDocument2 = _hash2;
  }

  function getGuaranteeClaim(uint64 _caseID) public view returns (uint8, address, bytes memory) {
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

  function setRejectPayment(uint64 _caseID, bytes32 _hash1, bytes32 _hash2) public {
    require(guaranteePayments[_caseID].status == 1, "Status must be 1 to reject payment");

    guaranteePayments[_caseID].status = 4;
    guaranteePayments[_caseID].sender = msg.sender;
    guaranteePayments[_caseID].rejectPaymentDocument1 = _hash1;
    guaranteePayments[_caseID].rejectPaymentDocument2 = _hash2;
  }

  function getRejectPayment(uint64 _caseID) public view returns (uint8, address, bytes memory) {
    uint8 status = guaranteePayments[_caseID].status;
    address sender = guaranteePayments[_caseID].sender;
    bytes32 p1 = guaranteePayments[_caseID].rejectPaymentDocument1;
    bytes32 p2 = guaranteePayments[_caseID].rejectPaymentDocument1;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p1)
      mstore(add(joined, 64), p2)
    }
    return (status, sender, joined);
  }

  function setAllowPayment(uint64 _caseID, bytes32 _hash1, bytes32 _hash2) public {
    require(guaranteePayments[_caseID].status == 1, "Status must be 1 to allow payment");

    guaranteePayments[_caseID].status = 2;
    guaranteePayments[_caseID].sender = msg.sender;
    guaranteePayments[_caseID].allowPaymentDocument1 = _hash1;
    guaranteePayments[_caseID].allowPaymentDocument2 = _hash2;
  }

  function getAllowPayment(uint64 _caseID) public view returns (uint8, address, bytes memory) {
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

  function setGuaranteeClaimGuarantor(uint64 _caseID, bytes32 _hash1, bytes32 _hash2) public {
    require(guaranteePayments[_caseID].status == 2, "Status must be 2 to set guarantor claim");

    guaranteePayments[_caseID].status = 3;
    guaranteePayments[_caseID].sender = msg.sender;
    guaranteePayments[_caseID].guaranteeClaimGuarantorDocument1 = _hash1;
    guaranteePayments[_caseID].guaranteeClaimGuarantorDocument2 = _hash2;
  }

  function getGuaranteeClaimGuarantor(uint64 _caseID) public view returns (uint8, address, bytes memory) {
    uint8 status = guaranteePayments[_caseID].status;
    address sender = guaranteePayments[_caseID].sender;
    bytes32 p1 = guaranteePayments[_caseID].guaranteeClaimGuarantorDocument1;
    bytes32 p2 = guaranteePayments[_caseID].guaranteeClaimGuarantorDocument2;
    bytes memory joined = new bytes(64);
    assembly {
      mstore(add(joined, 32), p1)
      mstore(add(joined, 64), p2)
    }
    return (status, sender, joined);
  }

}

