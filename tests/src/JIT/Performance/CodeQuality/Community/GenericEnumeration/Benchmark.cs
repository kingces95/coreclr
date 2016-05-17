using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Xunit.Performance;
using System.Runtime.CompilerServices;
using Xunit;
using System.Collections;
using System.Diagnostics;
using System.Threading;

[assembly: OptimizeForBenchmarks]
[assembly: MeasureInstructionsRetired]

public static class Template {

#if DEBUG
    private const int Iterations = 1;
#else
    private const int Iterations = 10000;
#endif
    private const int CollectionCount = 50000;

    private interface IGenericEnumerator<TCollection, TPosition, T> {
        int GetVersion(TCollection collection);
        TPosition StepForward(TPosition position);
        T GetValue(TCollection collection, TPosition position);
        bool Equals(TPosition lhs, TPosition rhs);
    }

    private struct GenericEnumerator<TOperations, TCollection, TPosition, T> : IEnumerator<T>
        where TOperations : struct, IGenericEnumerator<TCollection, TPosition, T> {

        private TOperations m_operations;
        private TCollection m_collection;
        private int m_version;
        private T m_current;
        private TPosition m_position;
        private TPosition m_begin;
        private TPosition m_end;

        internal GenericEnumerator(TCollection collection, TPosition begin, TPosition end) : this() {
            m_operations = default(TOperations);
            m_collection = collection;
            m_begin = begin;
            m_end = end;
            Reset();
        }

        private bool MoveLast() {
            if (m_operations.GetVersion(m_collection) != m_version)
                throw new InvalidOperationException();

            m_current = default(T);
            return false;
        }

        // jit dump: https://gist.github.com/kingces95/b0281b3d54f1c361fad63b3ab622c568
        public bool MoveNext() {
            var position = m_position;

            // For a given path through a method I expect at most one null check of the `this` pointer
            // however RyuJIT is actually generating subsequent checks so, in this benchmark, the gains 
            // of inlining calls on m_operations are (somewhat) offset by those extra null this checks.

            if (m_operations.GetVersion(m_collection) == m_version && !m_operations.Equals(position, m_end)) {
            //cmp      dword ptr [rsi], esi                 <-- expected null check
            //mov      rcx, gword ptr [rsi]
            //cmp      dword ptr [rsi+8], 0
            //jne      SHORT G_M61072_IG04
            //cmp      dword ptr [rsi], esi                 <-- unexpected null check
            //mov      ecx, dword ptr [rsi+24]
            //cmp      eax, ecx
            //je       SHORT G_M61072_IG04

                m_current = m_operations.GetValue(m_collection, position);
                //cmp      dword ptr [rsi], esi             <-- unexpected null check
                //mov      rcx, gword ptr [rsi]
                //cmp      eax, dword ptr [rcx+8]
                //jae      SHORT G_M61072_IG06
                //movsxd   rdx, eax
                //mov      ecx, dword ptr [rcx+4*rdx+16]
                //mov      dword ptr [rsi+12], ecx

                m_position = m_operations.StepForward(position);
                //cmp      dword ptr [rsi], esi             <-- unexpected null check
                //inc      eax
                //mov      dword ptr [rsi+16], eax

                return true;
            }

            return MoveLast();
        }

        public T Current => m_current;
        object IEnumerator.Current => m_current;

        public void Reset() {
            m_current = default(T);
            m_version = m_operations.GetVersion(m_collection);
            m_position = m_begin;
        }
        public void Dispose() {
            Reset();
            m_version = -1;
        }
    }

    private struct ArrayEnumerator<T> : IGenericEnumerator<T[], int, T> {
        public bool Equals(int lhs, int rhs) => lhs == rhs;
        public T GetValue(T[] collection, int position) => collection[position];
        public int GetVersion(T[] collection) => 0;
        public int StepForward(int iterator) => iterator + 1;
    }

    [MethodImpl(MethodImplOptions.NoInlining)]
    private static void Bench<TOperations, TCollection, TPosition, T>(
        GenericEnumerator<TOperations, TCollection, TPosition, T> enumerator)
        where TOperations : struct, IGenericEnumerator<TCollection, TPosition, T> {

        while (enumerator.MoveNext())
            continue;
    }

    private static void Bench() {
        var collection = new int[CollectionCount];
        var enumerator = new GenericEnumerator<ArrayEnumerator<int>, int[], int, int>(
            collection: collection,
            begin: 0,
            end: CollectionCount
        );

        Bench(enumerator);
    }

    [Benchmark]
    public static void Test() {
        foreach (var iteration in Benchmark.Iterations) {
            using (iteration.StartMeasurement()) {
                for (int i = 0; i < Iterations; i++)
                    Bench();
            }
        }
    }

    public static int Main() {

        for (int i = 0; i < Iterations; i++)
            Bench();

        return 100;
    }
}