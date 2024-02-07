import { useState } from 'react';
import { useContractRead } from 'wagmi';

import governorContractAbi from '@/abi/GovernorContract.json';

const governorContractAddress = '0x519b05b3655F4b89731B677d64CEcf761f4076f6';
const boxContractAddress = '0x31403b1e52051883f2Ce1B1b4C89f36034e1221D';

export function Propose() {
    const { data, isError, isLoading } = useContractRead({
        address: governorContractAddress,
        abi: governorContractAbi.abi,
        functionName: 'propose',
        args: [
            [boxContractAddress],
            [0],
            ['0x6057361d000000000000000000000000000000000000000000000000000000000000004d'],
            'propose from next description'
        ]
    });

    console.log({ data, isError, isLoading });

    return (
        <section>
            <h3>Propose</h3>
            <button>Propose</button>
        </section>
    )
}