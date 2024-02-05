'use client'

import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/react'

import { WagmiConfig } from 'wagmi'
import { arbitrum, mainnet, hardhat } from 'viem/chains'

// 1. Get projectId at https://cloud.walletconnect.com
const projectId = 'ca210b934365c21bab93aef50f47a550'

// 2. Create wagmiConfig
const metadata = {
    name: 'Web3Modal',
    description: 'Web3Modal Example',
    url: 'https://web3modal.com',
    icons: ['https://avatars.githubusercontent.com/u/37784886']
}

const chains = [mainnet, arbitrum, hardhat]
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata })

// 3. Create modal
createWeb3Modal({
    wagmiConfig,
    projectId,
    chains,
    enableAnalytics: true // Optional - defaults to your Cloud configuration
})

export function Web3Modal({ children }: Readonly<{ children: React.ReactNode }>) {
    return <WagmiConfig config={wagmiConfig}>{children}</WagmiConfig>
}
