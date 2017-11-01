// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Reflection.Emit;


public class Program {
    public static int Main(string[] args) {
        return 100;
    }
}

public class ImmutableArray<T> {
    public static implicit operator T[](ImmutableArray<T> self) => self.m_array;

    private readonly T[] m_array;

    public ImmutableArray() : this(new T[] { }) { }
    private ImmutableArray(T[] array) {
        m_array = array;
    }

    public ImmutableArray<T> Add(T element) {
        var oldLength = m_array.Length;
        var newArray = new T[oldLength + 1];
        Array.Copy(m_array, newArray, oldLength);
        newArray[oldLength] = element;
        return new ImmutableArray<T>(newArray);
    }
}

public class ParameterBuilder {
    private readonly string m_name;
    private readonly Type m_type;
    private readonly ImmutableArray<Type> m_optionalCustomModifiers;
    private readonly ImmutableArray<Type> m_requiredCustomModifiers;

    public ParameterBuilder() { }
    public ParameterBuilder(
        string name, 
        Type type,
        ImmutableArray<Type> optionalCustomModifiers,
        ImmutableArray<Type> requiredCustomModifiers) {

        m_name = name;
        m_type = type;
        m_optionalCustomModifiers = optionalCustomModifiers;
        m_requiredCustomModifiers = requiredCustomModifiers;
    }

    public string Name => m_name;
    public Type Type => m_type;
    public Type[] OptionalCustomModifiers => m_optionalCustomModifiers;
    public Type[] RequiredCustomModifiers => m_requiredCustomModifiers;

    public ParameterBuilder SetName(string name)
        => new ParameterBuilder(name, m_type, m_optionalCustomModifiers, m_requiredCustomModifiers);

    public ParameterBuilder SetType(Type type)
        => new ParameterBuilder(m_name, type, m_optionalCustomModifiers, m_requiredCustomModifiers);

    public ParameterBuilder AddOptionalCustomModifier(Type type)
        => new ParameterBuilder(m_name, m_type, m_optionalCustomModifiers.Add(type), m_requiredCustomModifiers);

    public ParameterBuilder AddRequiredCustomModifier(Type type)
        => new ParameterBuilder(m_name, m_type, m_optionalCustomModifiers, m_requiredCustomModifiers.Add(type));
}

public class SignatureBuilder {
    private readonly string m_name;
    private readonly ParameterBuilder m_returnParameter;
    private readonly ImmutableArray<ParameterBuilder> m_parameters;

    public SignatureBuilder() { }
    private SignatureBuilder(
        string name,
        ParameterBuilder returnParameter,
        ImmutableArray<ParameterBuilder> parameter) {

        m_name = name;
        m_returnParameter = returnParameter;
        m_parameters = parameter;
    }

    public string Name => m_name;
    public ParameterBuilder ReturnParameter => m_returnParameter;
    public ParameterBuilder[] Parameter => m_parameters;

    public SignatureBuilder SetName(string name)
        => new SignatureBuilder(name, m_returnParameter, m_parameters);

    public SignatureBuilder SetReturnParameter(ParameterBuilder returnParameter)
        => new SignatureBuilder(m_name, returnParameter, m_parameters);

    public SignatureBuilder AddParameter(ParameterBuilder returnParameter)
        => new SignatureBuilder(m_name, m_type, m_parameters.Add(returnParameter));
}

public class OverrideBuilder {

    private readonly SignatureBuilder m_declaration;
    private readonly SignatureBuilder m_body;

    public OverrideBuilder() { }
    private OverrideBuilder(
        SignatureBuilder declaration,
        SignatureBuilder body) {

        m_declaration = declaration;
        m_body = body;
    }

    private readonly SignatureBuilder Declaration => m_declaration;
    private readonly SignatureBuilder Body => m_body;

    public MethodBuilder SetDeclaration(SignatureBuilder declaration)
        => new OverrideBuilder(declaration, m_body);

    public MethodBuilder SetBody(SignatureBuilder body)
        => new OverrideBuilder(m_declaration, body);
}

public class OverrideTheory {
    private readonly string m_name;
    private readonly AssemblyBuilder m_assemblyBuilder;
    private readonly ModuleBuilder m_moduleBuilder;

    private int m_typeBuilderId = 0;

    public OverrideTheory() {
        m_name = GetType().FullName.Replace(".", "_");

        m_assemblyBuilder = AssemblyBuilder.DefineDynamicAssembly(
            new AssemblyName(m_name),
            AssemblyBuilderAccess.RunAndCollect
        );

        m_moduleBuilder = AssemblyBuilder.DefineDynamicModule(m_name);

        //var type = module.DefineType("Foo", TypeAttributes.Abstract);

        //var method = type.DefineMethod("M", methodAttributes);
        //var T = method.DefineGenericParameters("T")[0];
        //var EnumT = typeof(IEnumerable<>).MakeGenericType(T);
        //method.SetReturnType(EnumT);
        ////method.SetReturnType(typeof(object));

        //var methodOverride = type.DefineMethod("M_Override", methodAttributes);
        //var V = methodOverride.DefineGenericParameters("V")[0];
        //var EnumV = typeof(IEnumerable<>).MakeGenericType(V);
        //methodOverride.SetReturnType(EnumV);
        ////methodOverride.SetReturnType(typeof(string));

        //type.DefineMethodOverride(methodOverride, method);

        //type.CreateType();
    }

    private string NextTypeBuilderName()
        => $"TypeBuilder_{m_typeBuilderId++}";

    public TypeBuilder CreateAbstractType()
        => ModuleBuilder.DefineType(NextTypeBuilderName(), TypeAttributes.Abstract);
}
//public class AssignableTheory : OverrideTheory {

//    public class Test {
//        public Type GeneralType;
//        public Type SpecificType;
//    }


//    private static void CreateOverride(
//        string declaration, Type declarationReturnType, Type[] declarationArgumentTypes,
//        string body, Type bodyReturnType, Type[] bodyArgumentTypes) {

//    }

//    public static void ReturnTypeTheory(Test test) {

//    }
//}
