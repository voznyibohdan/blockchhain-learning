import { useState } from 'react';
import { useContractRead } from 'wagmi';

import governorContractAbi from '@/abi/GovernorContract.json';
import { ProposalState } from '@/components/proposal-state';

const governorContractAddress = '0x519b05b3655F4b89731B677d64CEcf761f4076f6';
const boxContractAddress = '0x31403b1e52051883f2Ce1B1b4C89f36034e1221D';
const encodedFunctionCall = '0x6057361d000000000000000000000000000000000000000000000000000000000000004d';

type ProposeProps = {
    value: number;
    description: string;
}

export function Propose({value, description}: ProposeProps) {
    const [showState, setShowState] = useState(false);

    const { data, isError, isLoading } = useContractRead({
        address: governorContractAddress,
        abi: governorContractAbi.abi,
        functionName: 'propose',
        args: [
            [boxContractAddress],
            [value],
            [encodedFunctionCall],
            description
        ]
    });

    console.log({ data, isError, isLoading });

    const handleShowState = () => {
        setShowState(true)
    }

    return (
        <section>
            <p>proposal id: {isLoading ? 'loading...' : data?.toString()}</p>
            <button onClick={handleShowState}>show state</button>
            {showState && <ProposalState id={data?.toString() as string} />}
        </section>
    )
}