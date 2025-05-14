#!/usr/bin/env python3

import subprocess
import json
import re
import argparse
from typing import Dict, List
from bip_utils import Bip39SeedGenerator, Bip39MnemonicValidator, Bip86, Bip86Coins


class DescriptorEntry:
    def __init__(self, desc: str):
        self.desc = desc
        # timestamp 0 means scan from the beginning
        self.timestamp = 0
        self.active = True
        self.internal = self._infer_internal(desc)
        self.next = 0
        self.next_index = 0

    def _infer_internal(self, desc: str) -> bool:
        # Infer internal from path: /1/* => internal, /0/* => external
        match = re.search(r"(\d+)/\*\)?#?", desc)
        if match:
            return match.group(1) == "1"
        raise ValueError(f"Could not parse internal/external from descriptor: {desc}")

    def to_dict(self) -> Dict:
        return {
            "desc": self.desc,
            "timestamp": self.timestamp,
            "active": self.active,
            "internal": self.internal,
            "next": self.next,
            "next_index": self.next_index
        }

    def to_string(self) -> str:
        return json.dumps(self.to_dict(), separators=(",", ":"))


def main():
    # Parse mnemonic from CLI argument
    parser = argparse.ArgumentParser(description="Generate descriptor file from mnemonic")
    parser.add_argument("mnemonic", type=str, help="BIP39 mnemonic phrase (quoted)")
    parser.add_argument("--runner",action="store",type=str, help="command runner e.g (bitcoin-cli)", default="bitcoin-cli")
    args = parser.parse_args()
    mnemonic = args.mnemonic
    command = list(filter(lambda x: x != "", args.runner.split(" ")))

    # Validate BIP39 mnemonic
    if not Bip39MnemonicValidator().IsValid(mnemonic):
        raise ValueError("Invalid BIP39 mnemonic")

    # Derive seed from mnemonic (empty passphrase)
    seed_bytes = Bip39SeedGenerator(mnemonic).Generate()

    # Derive BIP86 testnet account 0 xprv
    bip_obj = Bip86.FromSeed(seed_bytes, Bip86Coins.BITCOIN_TESTNET)
    xprv = bip_obj.Purpose().Coin().Account(0).PrivateKey().ToExtended()

    # Construct common descriptor templates (legacy, nested, native, taproot)
    descriptors = [
        f"pkh({xprv}/44h/1h/0h/0/*)",
        f"pkh({xprv}/44h/1h/0h/1/*)",
        f"sh(wpkh({xprv}/49h/1h/0h/0/*))",
        f"sh(wpkh({xprv}/49h/1h/0h/1/*))",
        f"tr({xprv}/86h/1h/0h/0/*)",
        f"tr({xprv}/86h/1h/0h/1/*)",
        f"wpkh({xprv}/84h/1h/0h/0/*)",
        f"wpkh({xprv}/84h/1h/0h/1/*)"
    ]

    descriptor_entries: List[DescriptorEntry] = []

    # Compute checksums using bitcoin-cli and build DescriptorEntry objects
    for desc in descriptors:
        descriptor_info = json.loads(
            subprocess.check_output([*command, "getdescriptorinfo", desc], text=True)
        )
        full_desc = f"{desc}#{descriptor_info['checksum']}"
        descriptor_entries.append(DescriptorEntry(full_desc))

    # Concatenate entries into a compact JSON array string
    concat_descriptors = "[" + ",".join(entry.to_string() for entry in descriptor_entries) + "]"

    # # Write final output to file
    # with open("file.dat", "w") as f:
    #     f.write(concat_descriptors)
    print(concat_descriptors)


if __name__ == "__main__":
    main()
