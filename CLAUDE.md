# Aztec Sandbox

This is a sandboxed environment for Aztec smart contract development with Claude Code. All tools are pre-installed and permissions are pre-configured for approval-free operation.

**Aztec version: `4.1.0`** (testnet)

## Important: LLMs and ZK Development

LLMs have limited training data for zero-knowledge circuit development and will make more mistakes than you might be used to. Always verify generated code and test thoroughly.

## Mandatory: Use Aztec MCP Server First

The Aztec API changes frequently. **Query the MCP server BEFORE writing any Aztec code.**

```
aztec_search_code() or aztec_search_docs()  →  verify current syntax  →  then write code
```

Use `aztec_sync_repos()` if the MCP server hasn't been initialized yet.

## CLI Rules

- **Always use the `aztec` CLI wrapper** — never call `nargo` directly
- `aztec compile` not `nargo compile`
- `aztec test` not `nargo test`

## Code Philosophy

- **Never silently swallow errors** — no fallback values like `AztecAddress.ZERO`
- Prefer explicit error throwing over null returns
- Fail fast and loud — a crash with a clear error is better than silent misbehavior
- **Default to Poseidon2** for hashing in Aztec.nr contracts

## Aztec is NOT Solidity

### Private State = Notes

- Notes are encrypted, off-chain data that only the owner can decrypt
- To "update" private state, consume (nullify) the old note and create a new one
- You cannot iterate over notes or query them like a database
- **Only the owner of a note can nullify (spend/replace/delete) it**

### Nullifiers Prevent Double-Spend

- Spending a note publishes its nullifier on-chain
- The protocol rejects transactions that reuse a nullifier

### Account Contracts Handle Auth

- Users deploy their own account contract defining auth rules
- `self.msg_sender()` returns `AztecAddress` (panics if None)
- `self.context.maybe_msg_sender()` returns `Option<AztecAddress>` for entrypoints
- msg_sender is **None** at tx entrypoints and in incognito enqueued public calls
- msg_sender in enqueued public calls is **visible on-chain** — use `self.enqueue_incognito()` to hide it

## Quick Reference

### Contract Template

```rust
use aztec::macros::aztec;

#[aztec]
pub contract MyContract {
    use aztec::macros::{functions::{external, initializer, view}, storage::storage};
    use aztec::protocol::address::AztecAddress;
    use aztec::state_vars::{Map, PublicMutable, Owned};

    #[storage]
    struct Storage<Context> {
        admin: PublicMutable<AztecAddress, Context>,
    }

    #[external("public")]
    #[initializer]
    fn constructor(admin: AztecAddress) {
        self.storage.admin.write(admin);
    }
}
```

### Function Attributes

| Attribute | Purpose |
|-----------|---------|
| `#[external("private")]` | Executes in PXE, reads/writes private state |
| `#[external("public")]` | Executes on sequencer, visible to everyone |
| `#[external("utility")]` + `unconstrained` | Off-chain reads without proofs |
| `#[view]` | Read-only |
| `#[internal("private")]` | Only callable by the contract itself (private) |
| `#[internal("public")]` | Only callable by the contract itself (public) |
| `#[initializer]` | Constructor |

### Common Commands

```bash
aztec compile                          # Compile contracts
aztec test                             # Run Noir TXE tests
aztec codegen target --outdir src/artifacts  # Generate TS artifacts
aztec start --local-network            # Start local network
```

### Simulate Before Send

Always call `.simulate()` before `.send()` for every state-changing transaction. Without simulation, failing transactions hang for up to 600 seconds with opaque errors.

```typescript
await contract.methods.myMethod(args).simulate({ from: account.address });
const tx = await contract.methods.myMethod(args).send({
    from: account.address,
    fee: { paymentMethod },
    wait: { timeout: 600 }
});
```

### Dependencies (Nargo.toml)

```toml
[package]
name = "my_contract"
type = "contract"

[dependencies]
aztec = { git = "https://github.com/AztecProtocol/aztec-nr/", tag = "v4.1.0", directory = "aztec" }
```

### Project Structure

```
project/
├── contracts/
│   └── my_contract/
│       ├── Nargo.toml
│       └── src/main.nr
├── src/index.ts
└── package.json
```

## Resources

- [Aztec Documentation](https://docs.aztec.network)
- [Noir Language](https://noir-lang.org)
- [Aztec GitHub](https://github.com/AztecProtocol/aztec-packages)
- [Aztec Starter](https://github.com/AztecProtocol/aztec-starter)
- [Aztec Examples](https://github.com/AztecProtocol/aztec-examples)
