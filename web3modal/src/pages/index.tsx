import Head from "next/head";
import Image from "next/image";
import styles from "@/styles/Home.module.css";
import { useEffect, useState } from 'react';
import { useAccount, useConnect, useContractRead, useNetwork } from 'wagmi';
import { fetchBalance, getContract, readContract } from '@wagmi/core';
import { boxAbi } from '@/abi/box.abi';
import { governorContractAbi } from '@/abi/governorContract.abi';

import BOX_ABI from '../abi/box.abi.json'
export default function Home() {
	const [isNetworkSwitchHighlighted, setIsNetworkSwitchHighlighted] = useState(false);
	const [isConnectHighlighted, setIsConnectHighlighted] = useState(false);

	const closeAll = () => {
		setIsNetworkSwitchHighlighted(false);
		setIsConnectHighlighted(false);
	};

	const governorContract = getContract({
		address: '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9',
		abi: governorContractAbi
	});

	const { data, isError, isLoading } = useContractRead({
		address: '0xa513E6E4b8f2a923D98304ec87F64353C4D5C853',
		abi: [BOX_ABI],
		functionName: 'value'
	});

	console.log({ data, isError, isLoading });

	return (
		<>
			<Head>
				<title>WalletConnect | Next Starter Template</title>
				<meta
					name="description"
					content="Generated by create-wc-dapp"
				/>
				<meta
					name="viewport"
					content="width=device-width, initial-scale=1"
				/>
				<link rel="icon" href="/favicon.ico" />
			</Head>
			<header>
				<div
					className={styles.backdrop}
					style={{
						opacity:
							isConnectHighlighted || isNetworkSwitchHighlighted
								? 1
								: 0,
					}}
				/>
				<div className={styles.header}>
					<div className={styles.logo}>
						<Image
							src="/logo.svg"
							alt="WalletConnect Logo"
							height="32"
							width="203"
						/>
					</div>
					<div className={styles.buttons}>
						<div
							onClick={closeAll}
							className={`${styles.highlight} ${
								isNetworkSwitchHighlighted
									? styles.highlightSelected
									: ``
							}`}
						>
							<w3m-network-button />
						</div>
						<div
							onClick={closeAll}
							className={`${styles.highlight} ${
								isConnectHighlighted
									? styles.highlightSelected
									: ``
							}`}
						>
							<w3m-button />
						</div>
					</div>
				</div>
			</header>
			<main className={styles.main}>
				<button onClick={() => {}}>get balance</button>
			</main>
		</>
	);
}
