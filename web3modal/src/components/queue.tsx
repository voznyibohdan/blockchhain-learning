import { useContractRead } from 'wagmi';
import governorContractAbi from '@/abi/GovernorContract.json';

export function Queue() {
    const hashedValue = '';

    const { data, isError, isLoading } = useContractRead({
        address: '0x519b05b3655F4b89731B677d64CEcf761f4076f6',
        abi: governorContractAbi.abi,
        functionName: 'queue',
        args: [
            ['0x31403b1e52051883f2Ce1B1b4C89f36034e1221D'],
            [0],
            ['0x6057361d000000000000000000000000000000000000000000000000000000000000004d'],
            hashedValue
        ]
    });

    console.log('Q U E U E');
    console.log({ data, isError, isLoading });

    return (
        <div>queue</div>
    )
}