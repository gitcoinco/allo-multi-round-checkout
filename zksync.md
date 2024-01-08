## Deployment on zksync


To deploy, remove from hardhat.config.ts:
```
	import "@openzeppelin/hardhat-upgrades";
	import "@matterlabs/hardhat-zksync-verify";
```

And add:

```
import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-upgradable";
import "@matterlabs/hardhat-zksync-verify";
```

To verify, remove
```
	import "@nomicfoundation/hardhat-toolbox";
	import "@openzeppelin/hardhat-upgrades";
```

And add
```
	import "@matterlabs/hardhat-zksync-verify";
```

npx hardhat verify --network zksyncEraGoerli 0x...
