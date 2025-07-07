import json
import csv
import os
import re
from web3 import Web3

# Connect to Ganache
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545"))

# Load contract ABI
with open("../blockchain/build/contracts/CGSContract.json") as f:
    abi = json.load(f)["abi"]

# Contract setup
contract_address = Web3.toChecksumAddress("0x3C3c87dF5d470d77658784f55212c33626d91534")
contract = w3.eth.contract(address=contract_address, abi=abi)

# Step: Find contract creation transaction
def find_creation_tx(contract_address, start_block=0, end_block='latest'):
    end_block = w3.eth.block_number if end_block == 'latest' else end_block
    for block_num in range(start_block, end_block + 1):
        block = w3.eth.get_block(block_num, full_transactions=True)
        for tx in block.transactions:
            if tx.to is None:
                receipt = w3.eth.get_transaction_receipt(tx.hash)
                if receipt.contractAddress and receipt.contractAddress.lower() == contract_address.lower():
                    return tx, receipt, block_num
    return None, None, None

# Parse .env file to build address->name mapping
env_file_path = "../src/.env"
address_name_map = {}

with open(env_file_path) as env_file:
    for line in env_file:
        match = re.match(r'(\w+)_ADDRESS="?(0x[a-fA-F0-9]{40})"?', line)
        if match:
            name, addr = match.groups()
            address_name_map[addr.lower()] = name

# Output CSV
output_file = "transactions_decoded.csv"
with open(output_file, mode='w', newline='') as csvfile:
    fieldnames = [
        "tx_block_number", "tx_hash", "tx_from", "sender_name", "tx_to", "tx_value_ether",
        "tx_gas", "tx_gas_price_wei", "tx_gas_used", "function_name"
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    # Write contract creation transaction
    creation_tx, creation_receipt, creation_block = find_creation_tx(contract_address)
    if creation_tx:
        creator = creation_tx["from"].lower()
        creator_name = address_name_map.get(creator, "UNKNOWN")
        writer.writerow({
            "tx_block_number": creation_block,
            "tx_hash": creation_tx.hash.hex(),
            "tx_from": creation_tx["from"],
            "sender_name": creator_name,
            "tx_to": "",  # no "to" for creation
            "tx_value_ether": w3.fromWei(creation_tx["value"], "ether"),
            "tx_gas": creation_tx["gas"],
            "tx_gas_price_wei": creation_tx["gasPrice"],
            "tx_gas_used": creation_receipt.gasUsed,
            "function_name": "ContractCreation"
        })
        print(f"Contract creation found in block {creation_block} with tx: {creation_tx.hash.hex()}")

    # Scan and decode function calls to the contract
    latest_block = w3.eth.block_number
    print(f"Scanning blocks 0 to {latest_block} for interactions with {contract_address}...")

    for block_number in range(latest_block + 1):
        block = w3.eth.get_block(block_number, full_transactions=True)
        for tx in block.transactions:
            if tx.to and tx.to.lower() == contract_address.lower():
                tx_receipt = w3.eth.get_transaction_receipt(tx.hash)
                try:
                    func_obj, func_args = contract.decode_function_input(tx.input)
                    func_name = func_obj.fn_name
                except:
                    func_name = ""

                sender = tx["from"].lower()
                sender_name = address_name_map.get(sender, "UNKNOWN")

                writer.writerow({
                    "tx_block_number": block_number,
                    "tx_hash": tx.hash.hex(),
                    "tx_from": tx["from"],
                    "sender_name": sender_name,
                    "tx_to": tx["to"],
                    "tx_value_ether": w3.fromWei(tx["value"], "ether"),
                    "tx_gas": tx["gas"],
                    "tx_gas_price_wei": tx["gasPrice"],
                    "tx_gas_used": tx_receipt.gasUsed,
                    "function_name": func_name,
                })

print(f"Decoded transaction data saved to: {output_file}")
