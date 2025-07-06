import pandas as pd

# Blockchain pricing data from the image (token price in EUR, gas price in GWEI)
blockchain_data = {
    "Ethereum": {"token": "ETH", "price_eur": 2226.55, "gas_price_gwei": 3},
    "Arbitrum_One": {"token": "ETH", "price_eur": 2226.55, "gas_price_gwei": 0.1},
    "Optimism": {"token": "ETH", "price_eur": 2226.55, "gas_price_gwei": 0.1},
    "Binance_Smart_Chain": {"token": "BNB", "price_eur": 563.19, "gas_price_gwei": 0.1},
    "Avalanche": {"token": "AVAX", "price_eur": 16, "gas_price_gwei": 1},
    "Polygon": {"token": "MATIC", "price_eur": 0.161765, "gas_price_gwei": 31},
    "Gnosis": {"token": "XDAI", "price_eur": 0.853378, "gas_price_gwei": 0.1},
    "Celo": {"token": "CELO", "price_eur": 0.241633, "gas_price_gwei": 1},
    "Fantom": {"token": "FTM", "price_eur": 0.284527, "gas_price_gwei": 1},
    "Harmony": {"token": "ONE", "price_eur": 0.00895701, "gas_price_gwei": 120}
}

# Load the CSV data from the user (as a list of dicts for demonstration)
csv_data = [
    {"tx_block_number": 2, "tx_hash": "0x0a315025c96a1cf952c771697b89731eff88c89961595ffa766df8cfeb3560c9", "tx_gas_used": 67131},
    {"tx_block_number": 3, "tx_hash": "0xcc4aeb2e53a040cdb2aba2968f0656ee141777ca7c080323b67a4f8f390b911a", "tx_gas_used": 67131},
    {"tx_block_number": 4, "tx_hash": "0x6f04bf03430f89b2b201548b9785fe243b32f4ee4cf201c55e3b13839d89a0cf", "tx_gas_used": 67131},
    {"tx_block_number": 5, "tx_hash": "0xe04fbe4c3b6820438416c382992db9ed3bf7407e49923290ec775ea18f29b762", "tx_gas_used": 67131},
    {"tx_block_number": 6, "tx_hash": "0xaf01e79fd7bef94af1394a05de812994ee0f212dc0d3c4f49563dd1358b0ce96", "tx_gas_used": 67131},
    {"tx_block_number": 7, "tx_hash": "0xed9e017bc38d804512e9ee155b2934f7a95baa7e9777427c20d2963beb5389d3", "tx_gas_used": 67556},
    {"tx_block_number": 8, "tx_hash": "0x8a09a4fbcc17d46c8cad088ef332754989686304199fafc11c81a1938d97ae1a", "tx_gas_used": 67733},
    {"tx_block_number": 9, "tx_hash": "0x2b3cd922df8f12c29dbe40e00c93200572b623cb673cd72fcacefce0c4ab1533", "tx_gas_used": 67733},
    {"tx_block_number": 10, "tx_hash": "0xcca27758c80192362f01877844a4d967e4eba1286d90fb5878af6f3f8fee87d0", "tx_gas_used": 113681},
    {"tx_block_number": 11, "tx_hash": "0x50999910bd2d36e65cbc069501a33a1ee7f69e24901e725b171a931805a448c6", "tx_gas_used": 113681},
    {"tx_block_number": 12, "tx_hash": "0x990b92be5d46b0f6c943d855bf2b6a75010b3eebee7ed41eeb2470576b50fc3c", "tx_gas_used": 67733},
    {"tx_block_number": 13, "tx_hash": "0xc6445ab5f2dca19b108c82992f47c8732c8bcea95b8909eeeec2b0d07fdc8375", "tx_gas_used": 159649},
    {"tx_block_number": 14, "tx_hash": "0x6b2dc94991bb3496dc3a482a94599c83e5e26050907bc099f7e04789fa60c08a", "tx_gas_used": 113681},
    {"tx_block_number": 15, "tx_hash": "0xfbd06730a5d980896db8cd37bcf66936ca7c54d19c3222fa6e41e07d81f07c63", "tx_gas_used": 159649},
    {"tx_block_number": 16, "tx_hash": "0x3651271858a9457a7c940824366cd1f6ebe800181191b74f8516c48de5fb9376", "tx_gas_used": 67733},
    {"tx_block_number": 17, "tx_hash": "0x882f6829d10c4b8112b269b6b6007f08ae7f54d100c5d82a6ea06371a439d965", "tx_gas_used": 159649},
    {"tx_block_number": 18, "tx_hash": "0x6ce1ca414a82e245e4c1d7bd731464d5094dc41518cfcccc72da2c116a107ad4", "tx_gas_used": 113681},
    {"tx_block_number": 19, "tx_hash": "0x2e010d390404ccfedb7222be480b306fb4316534ccdde103f7954450598a9cb5", "tx_gas_used": 159649},
    {"tx_block_number": 20, "tx_hash": "0x76b48582249326a5708f341c546fca6cec9bc8cbf43a5ff964668c46870b2d12", "tx_gas_used": 67776},
    {"tx_block_number": 21, "tx_hash": "0x4818c3370e4fc92f8840dfcb77f4c6564ca826b0864632994948c066aa99732c", "tx_gas_used": 67732},
    {"tx_block_number": 22, "tx_hash": "0x47921b188a85c3d13dcb3437ff70a0d56a8299ccdb68488b327e6622067879a3", "tx_gas_used": 67776},
    {"tx_block_number": 23, "tx_hash": "0x44a2d0d1f68444d9afbda336f36511a81d447e7679ca45c8d7f1c4250c8a7e59", "tx_gas_used": 67732},
    {"tx_block_number": 24, "tx_hash": "0x629ac77cc25a66c98d3b0ae840bccc049048e7b29c4c9cb2f738fbea0a27400c", "tx_gas_used": 67776},
    {"tx_block_number": 25, "tx_hash": "0x14ea8c5069385e8375bf0ecd0ac1e1ad6c0c1b92c4249892e46df7df7468860e", "tx_gas_used": 67776},
    {"tx_block_number": 26, "tx_hash": "0x8660aeffbb341aff689bf3b39d193a3f8ac0c3e99e03bf6384430f3834fa2966", "tx_gas_used": 67732},
    {"tx_block_number": 27, "tx_hash": "0x4b1f4b0c7da1d6b6cb02df60b4eda905045f5f299a5a3edd15bbb42300937a92", "tx_gas_used": 67732},
    {"tx_block_number": 28, "tx_hash": "0x869ea9508d5098def9bd084bdb790ebaa5aad9ce8b6cd060c2bce1c2bc3b1b0b", "tx_gas_used": 90513},
    {"tx_block_number": 29, "tx_hash": "0x93ff13992cf6f7accdb4c720cd6ee4cd4010b492e19a34d7fdb8674f7a0916ff", "tx_gas_used": 95262},
    {"tx_block_number": 30, "tx_hash": "0x038619519008e25dc9435cde25b531bfc56d21d4ed38a8a1b597df56abca9a64", "tx_gas_used": 95284},
    {"tx_block_number": 31, "tx_hash": "0xf5f12db896cdefa38c20f1d00d5a0315548cd2f3c89f63d8406e208f4878424d", "tx_gas_used": 90489},
    {"tx_block_number": 32, "tx_hash": "0xec23772e4684bb8b49eea89dbafee0c7340e94cb2f08502db37a1426a6340e76", "tx_gas_used": 73367},
    {"tx_block_number": 33, "tx_hash": "0x40cceca4a4a9537aa51d14170117d24954abb13227573d04e856fe76a8cd7cdb", "tx_gas_used": 90489},
    {"tx_block_number": 34, "tx_hash": "0x78a19de0b1413bd5b278847be293529de262a0798f580559ad0972c039d04b53", "tx_gas_used": 73390},
    {"tx_block_number": 35, "tx_hash": "0x502a2a5a53758789f6737e3dd30467b99665a287df701c8ef94be512bf34f0cd", "tx_gas_used": 73411},
    {"tx_block_number": 36, "tx_hash": "0x5f35b527906a21e20ae862b3875d836b7142ae8be5e77093776820dab3d98db8", "tx_gas_used": 90513},
    {"tx_block_number": 37, "tx_hash": "0xdfd23b5016a2aa3925f8714b0f964d1ee6532ae5c802390270a9a3735abf0171", "tx_gas_used": 95262},
    {"tx_block_number": 38, "tx_hash": "0x3353cdd160436b54e2af57c6b2ffcddaea60af2a16692ec87a02d156427df898", "tx_gas_used": 95284},
    {"tx_block_number": 39, "tx_hash": "0x3437db82c680bd5d36e0292350ca6767754717f1952478f406310a14b1b06c74", "tx_gas_used": 90489},
    {"tx_block_number": 40, "tx_hash": "0x2caedfa7c8376f41123c51e3ef645e00b181d31b12623a6ddda9ffeee31df609", "tx_gas_used": 73367},
    {"tx_block_number": 41, "tx_hash": "0x43184b0ed2c4605c86d11c5a26be1c36a2c99e262455062c3662cca30b131287", "tx_gas_used": 90489},
    {"tx_block_number": 42, "tx_hash": "0xcf1fcc3372e5877f0edab1146751204d794d4f54690a60fb4daf302cdcb37538", "tx_gas_used": 73390},
    {"tx_block_number": 43, "tx_hash": "0x16176a16595fef8e2793e993e07f06a0ea95bcc3f8e2f9b0f385c9d8ff38542f", "tx_gas_used": 73411}
]

# Create dataframe
df = pd.DataFrame(csv_data)

# Calculate cost for each blockchain
for chain, data in blockchain_data.items():
    token_price = data["price_eur"]
    gas_price_gwei = data["gas_price_gwei"]
    df[chain] = df["tx_gas_used"] * gas_price_gwei * 1e-9 * token_price

df.to_csv("gas_fees_output.csv", index=False)
print("Saved output to gas_fees_output.csv")
