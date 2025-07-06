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
        "block_number", "tx_hash", "from", "sender_name", "to", "value_ether",
        "gas", "gas_price_wei", "gas_used", "function_name"
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    # Track these functions only
    target_functions = {
        "setApplicationForm",
        "setGuaranteeConfirmation",
        "setLoanRequest",
        "setGuaranteeClaim",
        "setRejectPayment",
        "setAllowPayment",
        "setGuaranteeClaimGuarantor"
    }

    latest_block = w3.eth.block_number
    print(f"Scanning blocks 0 to {latest_block} for transactions to contract {contract_address}...\n")

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

                print(f"Block {block_number} | Tx: {tx.hash.hex()} | From: {sender_name} | Function: {func_name}")

                writer.writerow({
                    "block_number": block_number,
                    "tx_hash": tx.hash.hex(),
                    "from": tx["from"],
                    "sender_name": sender_name,
                    "to": tx["to"],
                    "value_ether": w3.fromWei(tx["value"], "ether"),
                    "gas": tx["gas"],
                    "gas_price_wei": tx["gasPrice"],
                    "gas_used": tx_receipt.gasUsed,
                    "function_name": func_name,
                })

print(f"\n Decoded transaction data saved to: {output_file}")
