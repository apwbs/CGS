import json
import csv
from web3 import Web3

# Connect to Ganache
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545"))

# Load contract ABI
with open("../blockchain/build/contracts/MARTSIAEth.json") as f:
    abi = json.load(f)["abi"]

# Contract setup
contract_address = Web3.toChecksumAddress("0xdaA30a4d411917548F16D2e2AE131421662f36a6")
contract = w3.eth.contract(address=contract_address, abi=abi)

# CSV output file
output_file = "transactions_decoded.csv"

# Prepare CSV
with open(output_file, mode='w', newline='') as csvfile:
    fieldnames = [
        "block_number", "tx_hash", "from", "to", "value_ether",
        "gas", "gas_price_wei", "gas_used", "function_name"
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    # Scan blocks
    latest_block = w3.eth.block_number
    print(f"Scanning blocks 0 to {latest_block} for transactions to contract {contract_address}...\n")

    # List of functions you want to track
    target_functions = {
        "setApplicationForm",
        "setGuaranteeConfirmation",
        "setLoanRequest",
        "setGuaranteeClaim",
        "setRejectPayment",
        "setAllowPayment",
        "setGuaranteeClaimGuarantor"
    }

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

                # Only log if function is in your list
                if func_name in target_functions:
                    print(f"Block {block_number} | Tx: {tx.hash.hex()} | Function: {func_name}")
                    writer.writerow({
                        "block_number": block_number,
                        "tx_hash": tx.hash.hex(),
                        "from": tx["from"],
                        "to": tx["to"],
                        "value_ether": w3.fromWei(tx["value"], "ether"),
                        "gas": tx["gas"],
                        "gas_price_wei": tx["gasPrice"],
                        "gas_used": tx_receipt.gasUsed,
                        "function_name": func_name,
                    })

print(f"\nDecoded transaction data saved to: {output_file}")
