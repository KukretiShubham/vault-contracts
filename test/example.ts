import { expect } from 'chai'
import { ethers, upgrades } from 'hardhat'

describe('ClubsVault', () => {
	describe('initialize', () => {
		describe('success', () => {
			it('initialize value', async () => {
				const Example = await ethers.getContractFactory('Example')
				const example = await upgrades.deployProxy(Example, [3n])
				const value: bigint = await example.value()
				expect(value).to.equal(3n)
			})
		})
		describe('fail', () => {
			it('should fail to initialize when already initialized', async () => {
				const Example = await ethers.getContractFactory('Example')
				const example = await upgrades.deployProxy(Example, [3n])

				await expect(example.initialize(6)).to.be.revertedWithCustomError(
					example,
					'InvalidInitialization',
				)
				const value: bigint = await example.value()
				expect(value).to.equal(3n)
			})
		})
	})

	describe('Scenarios', () => {
		describe('MOST SIMPLE: Every token balance will not change once received', () => {
			describe('Cycle 1: Vault has 100 ETH, 100 tokens.', () => {
				describe('Vault has 100 ETH(native token)', () => {
					it('Alice has 20%, and can withdraw 20 ETH.')

					it('Alice can not withdraw ETH now.')

					it('Bob has 30%, and can withdraw 30 ETH.')

					it('Bob can not withdraw ETH now.')

					it('Carol has 50%, and can withdraw 50 ETH.')

					it('Carol can not withdraw ETH now.')
				})
				describe('Vault has 100 tokens(ERC-20)', () => {
					it('Alice has 20%, and can withdraw 20 tokens.')

					it('Alice can not withdraw tokens now.')

					it('Bob has 30%, and can withdraw 30 tokens.')

					it('Bob can not withdraw tokens now.')

					it('Carol has 50%, and can withdraw 50 tokens.')

					it('Carol can not withdraw tokens now.')
				})
			})
			describe('Cycle 2: Vault reacquired 100 ETH, 100 tokens.', () => {
				describe('Vault has 100 ETH(native token)', () => {
					it('Alice has 20%, and can withdraw 20 ETH.')

					it('Alice can not withdraw ETH now.')

					it('Bob has 30%, and can withdraw 30 ETH.')

					it('Bob can not withdraw ETH now.')

					it('Carol has 50%, and can withdraw 50 ETH.')

					it('Carol can not withdraw ETH now.')
				})
				describe('Vault has 100 tokens(ERC-20)', () => {
					it('Alice has 20%, and can withdraw 20 tokens.')

					it('Alice can not withdraw tokens now.')

					it('Bob has 30%, and can withdraw 30 tokens.')

					it('Bob can not withdraw tokens now.')

					it('Carol has 50%, and can withdraw 50 tokens.')

					it('Carol can not withdraw tokens now.')
				})
			})
		})

		describe('Transfer the tokens to someone else after withdrawing', () => {
			describe('Cycle 1: Vault has 100 ETH, 100 tokens.', () => {
				describe('Vault has 100 ETH(native token)', () => {
					describe('Alice has 20%, and will send 10% to Bob after withdrawing. Bob will have 40%.', () => {
						it(
							'Alice has 20%, and can withdraw 20 ETH. Then, send 10% of tokens to Bob.',
						)

						it('Alice can not withdraw ETH now.')

						it('Bob has 40%, and can withdraw **30** ETH.')

						it('Bob can not withdraw ETH now.')

						it('Carol has 50%, and can withdraw 50 ETH.')

						it('Carol can not withdraw ETH now.')
					})
				})
				describe('Vault has 100 tokens(ERC-20)', () => {
					describe('Alice has 20%, and will send 10% to Bob after withdrawing. Bob will have 40%.', () => {
						it(
							'Alice has 20%, and can withdraw 20 tokens. Then, send 10% of tokens to Bob.',
						)

						it('Alice can not withdraw tokens now.')

						it('Bob has 40%, and can withdraw **30** tokens.')

						it('Bob can not withdraw tokens now.')

						it('Carol has 50%, and can withdraw 50 tokens.')

						it('Carol can not withdraw tokens now.')
					})
				})
			})
			describe('Cycle 2: Vault reacquired 100 ETH, 100 tokens.', () => {
				describe('Vault has 100 ETH(native token)', () => {
					it('Alice has 10%, and can withdraw 10 ETH.')

					it('Alice can not withdraw ETH now.')

					it('Bob has 40%, and can withdraw **40** ETH.')

					it('Bob can not withdraw ETH now.')

					it('Carol has 50%, and can withdraw 50 ETH.')

					it('Carol can not withdraw ETH now.')
				})
				describe('Vault has 100 tokens(ERC-20)', () => {
					it('Alice has 10%, and can withdraw 10 tokens.')

					it('Alice can not withdraw tokens now.')

					it('Bob has 40%, and can withdraw **40** tokens.')

					it('Bob can not withdraw tokens now.')

					it('Carol has 50%, and can withdraw 50 tokens.')

					it('Carol can not withdraw tokens now.')
				})
			})
		})

		describe('Token balance will decrease once but will increase again', () => {
			describe('Cycle 1: Vault has 100 ETH, 100 tokens.', () => {
				describe('Vault has 100 ETH(native token)', () => {
					describe('Alice has 20%, and will send 10% to Bob after withdrawing. Bob will have 40%. Carol will send 30% to Alice **before** withdrawing.', () => {
						it(
							'Alice has 20%, and can withdraw 20 ETH. Then, send 10% of tokens to Bob.',
						)

						it('Alice can not withdraw ETH now.')

						it('Bob has 40%, and can withdraw **30** ETH.')

						it('Bob can not withdraw ETH now.')

						it('Carol has 50%, and send 30% of tokens to Alice')

						it('Carol has 20% now, and can withdraw **20** ETH.')

						it('Carol can not withdraw ETH now.')

						it('Alice has 40%, and can withdraw **30** ETH now.')
					})
				})
				describe('Vault has 100 tokens(ERC-20)', () => {
					describe('Alice has 20%, and will send 10% to Bob after withdrawing. Bob will have 40%. Carol will send 30% to Alice **before** withdrawing.', () => {
						it(
							'Alice has 20%, and can withdraw 20 tokens. Then, send 10% of tokens to Bob.',
						)

						it('Alice can not withdraw tokens now.')

						it('Bob has 40%, and can withdraw **30** tokens.')

						it('Bob can not withdraw tokens now.')

						it('Carol has 50%, and send 30% of tokens to Alice')

						it('Carol has 20% now, and can withdraw **20** tokens.')

						it('Carol can not withdraw tokens now.')

						it('Alice has 40%, and can withdraw **30** tokens now.')
					})
				})
			})
			describe('Cycle 2: Vault reacquired 100 ETH, 100 tokens.', () => {
				describe('Vault has 100 ETH(native token)', () => {
					it('Alice has 40%, and can withdraw 40 ETH.')

					it('Alice can not withdraw ETH now.')

					it('Bob has 40%, and can withdraw **40** ETH.')

					it('Bob can not withdraw ETH now.')

					it('Carol has 20%, and can withdraw 20 ETH.')

					it('Carol can not withdraw ETH now.')
				})
				describe('Vault has 100 tokens(ERC-20)', () => {
					it('Alice has 40%, and can withdraw 40 tokens.')

					it('Alice can not withdraw tokens now.')

					it('Bob has 40%, and can withdraw **40** tokens.')

					it('Bob can not withdraw tokens now.')

					it('Carol has 50%, and can withdraw 50 tokens.')

					it('Carol can not withdraw tokens now.')
				})
			})
		})
	})
})
