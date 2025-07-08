import json
from web3 import Web3
from hexbytes import HexBytes

# Connect to local Ganache
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545"))

# Your deployed contract address
contract_address = Web3.toChecksumAddress("0x3C3c87dF5d470d77658784f55212c33626d91534")

# Helper to make receipts JSON-serializable
def serialize_receipt(receipt):
    def convert(value):
        if isinstance(value, HexBytes):
            return value.hex()
        elif isinstance(value, bytes):
            return value.hex()
        elif isinstance(value, list):
            return [convert(v) for v in value]
        elif isinstance(value, dict):
            return {k: convert(v) for k, v in value.items()}
        else:
            return value
    return convert(dict(receipt))

# Locate the contract creation transaction
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

# Gather all relevant receipts
filtered_receipts = []

# 1. Contract creation
creation_tx, creation_receipt, creation_block = find_creation_tx(contract_address)
if creation_tx:
    print(f"Contract creation found in block {creation_block}")
    filtered_receipts.append({
        "type": "ContractCreation",
        "block": creation_block,
        "tx_hash": creation_tx.hash.hex(),
        "receipt": serialize_receipt(creation_receipt)
    })

# 2. Contract interactions
latest_block = w3.eth.block_number
print(f"Scanning blocks 0 to {latest_block} for transactions to {contract_address}...")

for block_num in range(latest_block + 1):
    block = w3.eth.get_block(block_num, full_transactions=True)
    for tx in block.transactions:
        if tx.to and tx.to.lower() == contract_address.lower():
            try:
                receipt = w3.eth.get_transaction_receipt(tx.hash)
                filtered_receipts.append({
                    "type": "ContractInteraction",
                    "block": block_num,
                    "tx_hash": tx.hash.hex(),
                    "receipt": serialize_receipt(receipt)
                })
            except Exception as e:
                print(f"Error decoding tx {tx.hash.hex()}: {e}")

# 3. Write to file
output_file = "filtered_receipts.json"
with open(output_file, "w") as f:
    json.dump(filtered_receipts, f, indent=2)

print(f"Saved {len(filtered_receipts)} filtered receipts to {output_file}")
