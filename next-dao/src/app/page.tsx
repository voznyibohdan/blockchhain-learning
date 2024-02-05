'use client'

import styles from './page.module.css';
import { erc20ABI, erc721ABI, useContractRead } from 'wagmi';
import { useEffect } from 'react';

const contractAbi = [
    {
        "constant": true,
        "inputs": [],
        "name": "retrieve",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
];


export default function Home() {

    const { data, isError, isLoading } = useContractRead({
        address: '0xa513e6e4b8f2a923d98304ec87f64353c4d5c853',
        abi: contractAbi,
        functionName: 'retrieve',
    });

    console.log('retrieve function response: ', data);

    useEffect(() => {
        async function connectToContract() {
        }
    }, []);

    return (
        <main className={styles.main}>
            <w3m-button />
        </main>
    );
}
