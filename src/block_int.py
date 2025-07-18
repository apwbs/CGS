from web3 import Web3
from decouple import config
import json
import base64

# Connect to Ganache
ganache_url = "http://127.0.0.1:7545"
web3 = Web3(Web3.HTTPProvider(ganache_url))

compiled_contract_path = '../blockchain/build/contracts/CGSContract.json'
deployed_contract_address = config('CONTRACT_ADDRESS_CGS')

verbose = False

def get_nonce(ETH_address):
    # Retrieve the transaction count (nonce) for the given address
    return web3.eth.get_transaction_count(ETH_address)

def activate_contract(attribute_certifier_address, private_key):
    # Activate the contract by updating the majority count
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)
    tx = {
        'nonce': get_nonce(attribute_certifier_address),
        'gasPrice': web3.eth.gas_price,
        'from': attribute_certifier_address
    }
    message = contract.functions.updateMajorityCount().buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)

def __send_txt__(signed_transaction_type):
    # Send a signed transaction and handle failures
    try:
        transaction_hash = web3.eth.send_raw_transaction(signed_transaction_type)
        return transaction_hash
    except Exception as e:
        print(e)
        if input("Do you want to try again (y/n)?") == 'y':
            return __send_txt__(signed_transaction_type)
        else:
            raise Exception("Transaction failed")

def send_authority_names(authority_address, private_key, process_instance_id, hash_file):
    # Send name of Authority to the contract
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)
    tx = {
        'nonce': get_nonce(authority_address),
        'gasPrice': web3.eth.gas_price,
        'from': authority_address
    }
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)
    message = contract.functions.setAuthoritiesNames(int(process_instance_id), base64_bytes[:32],
                                                     base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)

def retrieve_authority_names(authority_address, process_instance_id):
    # Retrieve name of Authority from the contract
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)
    message = contract.functions.getAuthoritiesNames(authority_address, int(process_instance_id)).call()
    message_bytes = base64.b64decode(message)
    message = message_bytes.decode('ascii')
    return message

def sendHashedElements(authority_address, private_key, process_instance_id, elements):
    # Send hashed elements to the contract
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)
    tx = {
        'nonce': get_nonce(authority_address),
        'gasPrice': web3.eth.gas_price,
        'from': authority_address
    }
    hashPart1 = elements[0].encode('utf-8')
    hashPart2 = elements[1].encode('utf-8')
    message = contract.functions.setElementHashed(process_instance_id, hashPart1[:32], hashPart1[32:],
                                                  hashPart2[:32], hashPart2[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)

def retrieveHashedElements(eth_address, process_instance_id):
    # Retrieve hashed elements from the contract
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)
    message = contract.functions.getElementHashed(eth_address, process_instance_id).call()
    hashedg11 = message[0].decode('utf-8')
    hashedg21 = message[1].decode('utf-8')
    return hashedg11, hashedg21

def sendElements(authority_address, private_key, process_instance_id, elements):
    # Send elements to the contract
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)
    tx = {
        'nonce': get_nonce(authority_address),
        'gasPrice': web3.eth.gas_price,
        'from': authority_address
    }
    hashPart1 = elements[0]
    hashPart2 = elements[1]
    message = contract.functions.setElement(process_instance_id, hashPart1[:32], hashPart1[32:64],
                                            hashPart1[64:] + b'000000', hashPart2[:32], hashPart2[32:64],
                                            hashPart2[64:] + b'000000').buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)

def retrieveElements(eth_address, process_instance_id):
    # Retrieve elements from the contract
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)
    message = contract.functions.getElement(eth_address, process_instance_id).call()
    g11 = message[0] + message[1]
    g11 = g11[:90]
    g21 = message[2] + message[3]
    g21 = g21[:90]
    return g11, g21

def send_parameters_link(authority_address, private_key, process_instance_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(authority_address),
        'gasPrice': web3.eth.gas_price,
        'from': authority_address
    }
    
    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)
    
    # Build and sign the transaction
    message = contract.functions.setPublicParameters(int(process_instance_id), base64_bytes[:32],
                                                     base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    
    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieve_parameters_link(authority_address, process_instance_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve public parameters
    message = contract.functions.getPublicParameters(authority_address, int(process_instance_id)).call()
    message_bytes = base64.b64decode(message)
    return message_bytes.decode('ascii')


def send_publicKey_link(authority_address, private_key, process_instance_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(authority_address),
        'gasPrice': web3.eth.gas_price,
        'from': authority_address
    }
    
    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)
    
    # Build and sign the transaction
    message = contract.functions.setPublicKey(int(process_instance_id), base64_bytes[:32],
                                              base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    
    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieve_publicKey_link(eth_address, process_instance_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the public key
    message = contract.functions.getPublicKey(eth_address, int(process_instance_id)).call()
    message_bytes = base64.b64decode(message)
    return message_bytes.decode('ascii')


def send_MessageIPFSLink(dataOwner_address, private_key, message_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(dataOwner_address),
        'gasPrice': web3.eth.gas_price,
        'from': dataOwner_address
    }
    
    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)
    
    # Build and sign the transaction
    message = contract.functions.setIPFSLink(int(message_id), base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    
    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieve_MessageIPFSLink(message_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the IPFS link
    message = contract.functions.getIPFSLink(int(message_id)).call()
    sender = message[0]
    message_bytes = base64.b64decode(message[1])
    ipfs_link = message_bytes.decode('ascii')
    return ipfs_link, sender


def send_users_attributes(attribute_certifier_address, private_key, process_instance_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(attribute_certifier_address),
        'gasPrice': web3.eth.gas_price,
        'from': attribute_certifier_address
    }
    
    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)
    
    # Build and sign the transaction
    message = contract.functions.setUserAttributes(int(process_instance_id), base64_bytes[:32],
                                                   base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    
    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieve_users_attributes(process_instance_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve user attributes
    message = contract.functions.getUserAttributes(int(process_instance_id)).call()
    message_bytes = base64.b64decode(message)
    return message_bytes.decode('ascii')


def send_publicKey_readers(reader_address, private_key, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(reader_address),
        'gasPrice': web3.eth.gas_price,
        'from': reader_address
    }
    
    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)
    
    # Build and sign the transaction
    message = contract.functions.setPublicKeyReaders(base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)
    
    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieve_publicKey_readers(reader_address):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the public key of a Reader
    message = contract.functions.getPublicKeyReaders(reader_address).call()
    message_bytes = base64.b64decode(message)
    return message_bytes.decode('ascii')






def sendApplicationForm(dataOwner_address, private_key, case_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(dataOwner_address),
        'gasPrice': web3.eth.gas_price,
        'from': dataOwner_address
    }

    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)

    # Build and sign the transaction
    message = contract.functions.setApplicationForm(int(case_id), base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)

    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieveApplicationForm(case_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the IPFS link
    message = contract.functions.getApplicationForm(int(case_id)).call()
    status = message[0]
    sender = message[1]
    message_bytes = base64.b64decode(message[2])
    ipfs_link = message_bytes.decode('ascii').strip()
    return status, ipfs_link, sender



def sendGuaranteeConfirmation(dataOwner_address, private_key, case_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(dataOwner_address),
        'gasPrice': web3.eth.gas_price,
        'from': dataOwner_address
    }

    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)

    # Build and sign the transaction
    message = contract.functions.setGuaranteeConfirmation(int(case_id), base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)

    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieveGuaranteeConfirmation(case_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the IPFS link
    message = contract.functions.getGuaranteeConfirmation(int(case_id)).call()
    status = message[0]
    sender = message[1]
    message_bytes = base64.b64decode(message[2])
    ipfs_link = message_bytes.decode('ascii')
    return status, ipfs_link, sender



def sendLoanRequest(dataOwner_address, private_key, case_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(dataOwner_address),
        'gasPrice': web3.eth.gas_price,
        'from': dataOwner_address
    }

    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)

    # Build and sign the transaction
    message = contract.functions.setLoanRequest(int(case_id), base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)

    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieveLoanRequest(case_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the IPFS link
    message = contract.functions.getLoanRequest(int(case_id)).call()
    status = message[0]
    sender = message[1]
    message_bytes = base64.b64decode(message[2])
    ipfs_link = message_bytes.decode('ascii')
    return status, ipfs_link, sender


def sendGuaranteeClaim(dataOwner_address, private_key, case_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(dataOwner_address),
        'gasPrice': web3.eth.gas_price,
        'from': dataOwner_address
    }

    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)

    # Build and sign the transaction
    message = contract.functions.setGuaranteeClaim(int(case_id), base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)

    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieveGuaranteeClaim(case_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the IPFS link
    message = contract.functions.getGuaranteeClaim(int(case_id)).call()
    status = message[0]
    sender = message[1]
    message_bytes = base64.b64decode(message[2])
    ipfs_link = message_bytes.decode('ascii')
    return status, ipfs_link, sender


def sendRejectPayment(dataOwner_address, private_key, case_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(dataOwner_address),
        'gasPrice': web3.eth.gas_price,
        'from': dataOwner_address
    }

    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)

    # Build and sign the transaction
    message = contract.functions.setRejectPayment(int(case_id), base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)

    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieveRejectPayment(case_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the IPFS link
    message = contract.functions.getRejectPayment(int(case_id)).call()
    status = message[0]
    sender = message[1]
    message_bytes = base64.b64decode(message[2])
    ipfs_link = message_bytes.decode('ascii')
    return status, ipfs_link, sender


def sendAllowPayment(dataOwner_address, private_key, case_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(dataOwner_address),
        'gasPrice': web3.eth.gas_price,
        'from': dataOwner_address
    }

    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)

    # Build and sign the transaction
    message = contract.functions.setAllowPayment(int(case_id), base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)

    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieveAllowPayment(case_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the IPFS link
    message = contract.functions.getAllowPayment(int(case_id)).call()
    status = message[0]
    sender = message[1]
    message_bytes = base64.b64decode(message[2])
    ipfs_link = message_bytes.decode('ascii')
    return status, ipfs_link, sender


def sendGuaranteeClaimGuarantor(dataOwner_address, private_key, case_id, hash_file):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Prepare transaction details
    tx = {
        'nonce': get_nonce(dataOwner_address),
        'gasPrice': web3.eth.gas_price,
        'from': dataOwner_address
    }

    # Encode the hash file for the transaction
    message_bytes = hash_file.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)

    # Build and sign the transaction
    message = contract.functions.setGuaranteeClaimGuarantor(int(case_id), base64_bytes[:32], base64_bytes[32:]).buildTransaction(tx)
    signed_transaction = web3.eth.account.sign_transaction(message, private_key)

    # Send the transaction and wait for receipt
    transaction_hash = __send_txt__(signed_transaction.rawTransaction)
    print(f'tx_hash: {web3.toHex(transaction_hash)}')
    tx_receipt = web3.eth.wait_for_transaction_receipt(transaction_hash, timeout=600)
    if verbose:
        print(tx_receipt)


def retrieveGuaranteeClaimGuarantor(case_id):
    # Load contract ABI and create a contract instance
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
        contract_abi = contract_json['abi']
    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    # Call the contract function to retrieve the IPFS link
    message = contract.functions.getGuaranteeClaimGuarantor(int(case_id)).call()
    status = message[0]
    sender = message[1]
    message_bytes = base64.b64decode(message[2])
    ipfs_link = message_bytes.decode('ascii')
    return status, ipfs_link, sender