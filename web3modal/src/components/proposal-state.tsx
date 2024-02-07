import { useContractRead } from 'wagmi';
import governorContractAbi from '@/abi/GovernorContract.json';

export function ProposalState({id}: {id:string}) {
    const { data, isError, isLoading } = useContractRead({
        address: '0x519b05b3655F4b89731B677d64CEcf761f4076f6',
        abi: governorContractAbi.abi,
        functionName: 'state',
        args: ['60626972191260840030055398339342904059712141251632123558487121654863128058818']
    });

    console.log({ data, isError, isLoading });

    return (
        <div></div>
    )
}