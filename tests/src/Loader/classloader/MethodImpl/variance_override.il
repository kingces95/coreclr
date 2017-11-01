// CompareTypeDefsForVariance
// EnumerateMethodImpls

.assembly variance_override { }
.assembly extern mscorlib { }

// class hierarchy
.class public abstract A { }
.class public abstract B extends A { }
.class public abstract C extends B { }
.class public abstract D0 extends C { }
.class public abstract D1 extends C { }
.class public abstract D2 extends C { }

// generic class hierarchy
.class public abstract A`1<T> { }
.class public abstract B`1<T> extends class A`1<!T> { }
.class public abstract C`1<T> extends class B`1<!T> { }
.class public abstract D0`1<T> extends class C`1<!T> { }
.class public abstract D1`1<T> extends class C`1<!T> { }
.class public abstract D2`1<T> extends class C`1<!T> { }

// mixed class hierarchy
.class public abstract XA { }
.class public abstract XB`1<T> extends XA { }
.class public abstract XC extends class XB`1<class C> { }

// class hierarchy nested
.class public NA { }
.class public N { .class rtspecialname nested public NB extends NA { } }
.class public NC extends N/NB { }

// interface hierarchy
.class interface public abstract IA { }
.class interface public abstract IB implements IA { }
.class interface public abstract IC implements IB { }

// generic interface hierarchy
.class interface public abstract IA`1<T> { }
.class interface public abstract IB`1<T> implements class IA`1<!T> { }
.class interface public abstract IC`1<T> implements class IB`1<!T> { }

.class public value sealed StructIA implements IA { }

// loosened constraint generic parameter (explicit)
.class public abstract MethodConstraint {
  .method public abstract virtual !!T M0<(C) T>(!!T arg) { }
}
.class public abstract MethodConstraintWeaker extends MethodConstraint {
    // If an override with weaker constraints throws...
  .method public abstract virtual !!T M1<(B) T>(!!T arg) { .override .base::M0 }
}
.class public abstract MethodConstraintWeakest extends MethodConstraint {
    // ...then an override with _no_ constraints at all should certainly throw!
  .method public abstract virtual !!T M1<T>(!!T arg) { .override .base::M0 }
}
.class public abstract MethodConstraintStrongAgain extends MethodConstraintWeakest {
    // And this should always throw!! (see IDS_CLASSLOAD_CONSTRAINT_MISMATCH_ON_EXISTING_IMPL)
  .method public abstract virtual !!T M2<(C) T>(!!T arg) { .override .base::M0 }
}

// loosened constraint generic parameter (implicit)
.class public abstract MethodConstraintImplicit {
  .method public abstract virtual !!T M<(C) T>(!!T arg) { }
}
.class public abstract MethodConstraintImplicitWeaker extends MethodConstraintImplicit {
  .method public abstract virtual !!T M<(B) T>(!!T arg) { }
}
.class public abstract MethodConstraintImplicitWeakest extends MethodConstraintImplicit {
  .method public abstract virtual !!T M<T>(!!T arg) { }
}
.class public abstract MethodConstraintImplicitStrongerAgain extends MethodConstraintImplicitWeaker {
    // will throw if MethodConstraintImplicitWeaker.M implicitly overrides MethodConstraintImplicit.M
  .method public abstract virtual !!T M<(C) T>(!!T arg) { }
}
.class public abstract MethodConstraintImplicitStrongAgain extends MethodConstraintImplicitWeakest {
    // will throw if MethodConstraintImplicitWeakest.M implicitly overrides MethodConstraintImplicit.M
  .method public abstract virtual !!T M<(C) T>(!!T arg) { }
}

// loosened constraint generic parameter (explicit interface)
.class interface public abstract MethodIConstraint {
  .method public newslot abstract virtual instance !!T  M0<(C) T>(!!T arg) { }
}
.class public abstract MethodIConstraintWeaker implements MethodIConstraint {
  .method public newslot abstract virtual instance !!T  M1<(B) T>(!!T arg) { .override MethodIConstraint::M0 }
}
.class public abstract MethodIConstraintWeakest implements MethodIConstraint {
  .method public newslot abstract virtual instance !!T  M1<T>(!!T arg) { .override MethodIConstraint::M0 }
}

// loosened constraint generic parameter (implicit interface)
.class interface public abstract MethodIConstraintImplicit {
  .method public newslot abstract virtual instance !!T  M<(C) T>(!!T arg) { }
}
.class public abstract MethodIConstraintImplicitWeaker implements MethodIConstraintImplicit {
  .method public newslot abstract virtual instance !!T  M<(B) T>(!!T arg) { }
}
.class public abstract MethodIConstraintImplicitWeakest implements MethodIConstraintImplicit {
  .method public newslot abstract virtual instance !!T  M<T>(!!T arg) { }
}
.class public abstract MethodIConstraintImplicitStrongerAgain extends MethodIConstraintImplicitWeaker {
    // will throw if MethodIConstraintImplicitWeaker.M implicitly overrides MethodIConstraintImplicit.M
  .method public abstract virtual !!T M<(C) T>(!!T arg) { }
}
.class public abstract MethodIConstraintImplicitStrongAgain extends MethodIConstraintImplicitWeakest {
    // will throw if MethodIConstraintImplicitWeakest.M implicitly overrides MethodIConstraintImplicit.M
  .method public abstract virtual !!T M<(C) T>(!!T arg) { }
}

// overload
.class public abstract Overload {
  .method public abstract virtual void M(class C arg) { }
  .method public abstract virtual void M(class D0 arg) { }
  .method public abstract virtual void M(class D1 arg) { }
}
.class public abstract Overload3For3 extends Overload {
    // entice the loader with various override options for each method. If the loader chooses the wrong
    // option then more than one body would be chosen for a declaration which would throw.

    // both are variant with M(C) but expect neither to bind to M(C). If either did bind to M(C),
    // then that would indicate that variant binding is unexpectedly occuring when searching for the 
    // declaration. Variant binding should occur between explicit .overrides and the enclosing method.
  .method public abstract virtual void M_D0(class B arg) { 
    .override  method instance void class .base::M(class D0) // pick M(D0)
  }
  .method public abstract virtual void M_D1(class B arg) { 
    .override  method instance void class .base::M(class D1) // pick M(D1)
  }

  .method public abstract virtual void M_C(class C arg) { 
    .override .base::M // implicit signature M(C); pick M(C)
  }
}
.class public abstract OverloadImplicitBad extends Overload {
  .method public abstract virtual void M(class D2 arg) {
    // explicit
    // .override  method instance void class Overload::M(class D2)

    // implicit
     // entice with with M(C) but expect MissingMethodException
    .override .base::M
  }
}
.class public abstract OverloadExplictBad extends Overload {
  .method public abstract virtual void M_D1(class C arg) { 
    // entice with M(C) but expect MissingMethodException
    .override  method instance void class .base::M(class D2) // M(D2) missing
  }
}

// covariant
.class public abstract Covariant {
  .method public abstract virtual object M() { }
}
.class public abstract CovariantString extends Covariant {
  .method public abstract virtual string M() { .override method instance object class .base::M() }
}
.class public abstract CovariantClass extends Covariant {
  .method public abstract virtual class CovariantClass M() { .override method instance object class .base::M() }
}
.class public abstract CovariantArray extends Covariant {
  .method public abstract virtual object[0...] M() { .override method instance object class .base::M() }
}
.class public abstract CovariantStringArray extends Covariant {
  .method public abstract virtual string[0...] M() { .override method instance object class .base::M() }
}
.class public abstract CovariantSZArray extends Covariant {
  .method public abstract virtual object[] M() { .override method instance object class .base::M() }
}
.class public abstract CovariantSZArraySZArray extends Covariant {
  .method public abstract virtual object[][] M() { .override method instance object class .base::M() }
}

// covariant derived class
.class public abstract CovariantDerivedA {
  .method public abstract virtual class A M() { }
}
.class public abstract CovariantDerivedAB extends CovariantDerivedA {
  .method public abstract virtual class B M() { .override method instance class A .base::M() }
}
.class public abstract CovariantDerivedAC extends CovariantDerivedA {
  .method public abstract virtual class C M() { .override method instance class A .base::M() }
}
.class public abstract CovariantDerivedABC extends CovariantDerivedAB {
  .method public abstract virtual class C M() { .override method instance class A .base::M() }
}
.class public abstract CovariantDerivedACB extends CovariantDerivedAC {
  .method public abstract virtual class B M() { .override method instance class A .base::M() }
}

// covariant derived class nested
.class public abstract CovariantDerivedNA {
  .method public abstract virtual class NA M() { }
}
.class public abstract CovariantDerivedNB extends CovariantDerivedNA {
  .method public abstract virtual class N/NB M() { .override method instance class NA .base::M() }
}
.class public abstract CovariantDerivedNC extends CovariantDerivedNB {
  .method public abstract virtual class NC M() { .override method instance class N/NB .base::M() }
}

// covariant derived generic class
.class public abstract CovariantA`1<T> {
  .method public abstract virtual class A`1<!T> M() { }
}
.class public abstract CovariantAB`1<T> extends class CovariantA`1<!T> {
  .method public abstract virtual class B`1<!T> M() { .override method instance class A`1<!T> class CovariantA`1<!T>::M() }
}
.class public abstract CovariantAC`1<T> extends class CovariantA`1<!T> {
  .method public abstract virtual class C`1<!T> M() { .override method instance class A`1<!T> class CovariantA`1<!T>::M() }
}
.class public abstract CovariantABC`1<T> extends class CovariantAB`1<!T> {
  .method public abstract virtual class C`1<!T> M() { .override method instance class A`1<!T> class CovariantA`1<!T>::M() }
}
.class public abstract CovariantACB`1<T> extends class CovariantAC`1<!T> {
  .method public abstract virtual class B`1<!T> M() { .override method instance class A`1<!T> class CovariantA`1<!T>::M() }
}

// covariant derived mixed class
.class public abstract CovariantMixedA {
  .method public abstract virtual class XA M() { }
}
.class public abstract CovariantMixedB extends CovariantMixedA {
  .method public abstract virtual class XB`1<class C> M() { .override method instance class XA class .base::M() }
}
.class public abstract CovariantMixedC extends CovariantMixedB {
  .method public abstract virtual class XC M() { .override method instance class XB`1<class C> class .base::M() }
}

// covariant derived interface
.class public abstract CovariantIA {
  .method public abstract virtual class IA M() { }
}
.class public abstract CovariantIAB extends CovariantIA {
  .method public abstract virtual class IB M() { .override method instance class IA class .base::M() }
}
.class public abstract CovariantIAC extends CovariantIA {
  .method public abstract virtual class IC M() { .override method instance class IA class .base::M() }
}
.class public abstract CovariantIABC extends CovariantIAB {
  .method public abstract virtual class IC M() { .override method instance class IB class .base::M() }
}
.class public abstract CovariantIACB extends CovariantIAC {
  .method public abstract virtual class IB M() { .override method instance class IC class .base::M() }
}
.class public abstract CovariantStructIA extends CovariantIA {
  .method public abstract virtual class StructIA M() { .override method instance class IA class .base::M() }
}

// covariant derived generic interface
.class public abstract CovariantIA`1<T> {
  .method public abstract virtual class IA`1<!T> M() { }
}
.class public abstract CovariantIAB`1<T> extends class CovariantIA`1<!T> {
  .method public abstract virtual class IB`1<!T> M() { .override method instance class IA`1<!T> class CovariantIA`1<!T>::M() }
}
.class public abstract CovariantIAC`1<T> extends class CovariantIA`1<!T> {
  .method public abstract virtual class IC`1<!T> M() { .override method instance class IA`1<!T> class CovariantIA`1<!T>::M() }
}
.class public abstract CovariantIABC`1<T> extends class CovariantIAB`1<!T> {
  .method public abstract virtual class IC`1<!T> M() { .override method instance class IA`1<!T> class CovariantIA`1<!T>::M() }
}
.class public abstract CovariantIACB`1<T> extends class CovariantIAC`1<!T> {
  .method public abstract virtual class IB`1<!T> M() { .override method instance class IA`1<!T> class CovariantIA`1<!T>::M() }
}

// contravariant
.class public abstract Contravariant {
  .method public abstract virtual void M(string arg) { }
  .method public abstract virtual void M(class Contravariant arg) { }
  .method public abstract virtual void M(object[0...] arg) { }
  .method public abstract virtual void M(string[0...] arg) { }
  .method public abstract virtual void M(object[] arg) { }
  .method public abstract virtual void M(object[][] arg) { }
}
.class public abstract ContravariantString extends Contravariant {
  .method public abstract virtual void M(object arg) { .override method instance void class .base::M(string) }
}
.class public abstract ContravariantClass extends Contravariant {
  .method public abstract virtual void M(object arg) { .override method instance void class .base::M(class Contravariant) }
}
.class public abstract ContravariantArray extends Contravariant {
  .method public abstract virtual void M(object arg) { .override method instance void class .base::M(object[0...]) }
}
.class public abstract ContravariantStringArray extends Contravariant {
  .method public abstract virtual void M(object[0...] arg) { .override method instance void class .base::M(string[0...]) }
}
.class public abstract ContravariantSzArray extends Contravariant {
  .method public abstract virtual void M(object arg) { .override method instance void class .base::M(object[]) }
}
.class public abstract ContravariantSzArraySzArray extends Contravariant {
  .method public abstract virtual void M(object arg) { .override method instance void class .base::M(object[][]) }
}

// contravariant derived class
.class public abstract ContravariantDerivedC {
  .method public abstract virtual void M(class C arg) { }
}
.class public abstract ContravariantDerivedCB extends ContravariantDerivedC {
  .method public abstract virtual void M(class B arg) { .override method instance void class .base::M(class C) }
}
.class public abstract ContravariantDerivedCA extends ContravariantDerivedC {
  .method public abstract virtual void M(class A arg) { .override method instance void class .base::M(class C) }
}

// covariant derived interface
.class public abstract ContravariantIA {
  .method public abstract virtual void M(class IA) { }
  .method public abstract virtual void M(class IC) { }
}
.class public abstract ContravariantICB extends ContravariantIA {
  .method public abstract virtual void M(class IB) { .override method instance void class .base::M(class IC) }
}
.class public abstract ContravariantICA extends ContravariantIA {
  .method public abstract virtual void M(class IA) { .override method instance void class .base::M(class IC) }
}
.class public abstract ContravariantStructIA extends ContravariantIA {
  .method public abstract virtual void M(class StructIA) { .override method instance void class .base::M(class IA) }
}

.class private abstract sealed beforefieldinit Program {
  .method private static int32 Run() {
    .entrypoint

    //ldstr "CovariantIACB" call void Program::Load(string) br EXIT

    call       void Program::Covariant()
    call       void Program::Contravariant()
    call       void Program::Overload()
    call       void Program::GenericParameterConstraint()
    call       void Program::CovariantGeneric()
    br         EXIT
    call       void Program::BadTypeLoadException()

    EXIT:  
    ldc.i4.s   100
    ret
  }

  .method private static void Overload() {

    ldstr      "Overload3For3"
    call       void Program::Load(string)

    ldstr      "OverloadImplicitBad"
    call       void Program::LoadThrowsMissingMethodException(string)

    ldstr      "OverloadExplictBad"
    call       void Program::LoadThrowsMissingMethodException(string)

    ret
  }
  .method private static void CovariantGeneric() {

    ldstr      "CovariantAB`1"
    call       void Program::Load(string)

    ldstr      "CovariantAC`1"
    call       void Program::Load(string)

    ldstr      "CovariantABC`1"
    call       void Program::Load(string)

    ldstr      "CovariantIAB`1"
    call       void Program::Load(string)

    ldstr      "CovariantIAC`1"
    call       void Program::Load(string)

    ldstr      "CovariantIABC`1"
    call       void Program::Load(string)

    ldstr      "CovariantMixedB"
    call       void Program::Load(string)

    ldstr      "CovariantMixedC"
    call       void Program::Load(string)

    ldstr      "CovariantACB`1"
    call       void Program::LoadThrowsTypeLoadException(string)

    ldstr      "CovariantIACB`1"
    call       void Program::LoadThrowsTypeLoadException(string)

    ret
  }
  .method private static void Covariant() {

    ldstr      "CovariantString"
    call       void Program::Load(string)

    ldstr      "CovariantClass"
    call       void Program::Load(string)

    ldstr      "CovariantArray"
    call       void Program::Load(string)

    ldstr      "CovariantStringArray"
    call       void Program::Load(string)

    ldstr      "CovariantSZArray"
    call       void Program::Load(string)

    ldstr      "CovariantSZArraySZArray"
    call       void Program::Load(string)

    ldstr      "CovariantDerivedAB"
    call       void Program::Load(string)

    ldstr      "CovariantDerivedAC"
    call       void Program::Load(string)

    ldstr      "CovariantDerivedACB"
    call       void Program::LoadThrowsTypeLoadException(string)

    ldstr      "CovariantDerivedNC"
    call       void Program::Load(string)

    ldstr      "CovariantIAB"
    call       void Program::Load(string)

    ldstr      "CovariantIAC"
    call       void Program::Load(string)

    ldstr      "CovariantIABC"
    call       void Program::Load(string)

    ldstr      "CovariantIACB"
    call       void Program::LoadThrowsTypeLoadException(string)

    ldstr      "CovariantStructIA"
    call       void Program::LoadThrowsTypeLoadException(string)

    ret
  }
  
  .method private static void Contravariant() {

    ldstr      "ContravariantString"
    call       void Program::Load(string)

    ldstr      "ContravariantClass"
    call       void Program::Load(string)

    ldstr      "ContravariantArray"
    call       void Program::Load(string)

    ldstr      "ContravariantStringArray"
    call       void Program::Load(string)

    ldstr      "ContravariantSZArray"
    call       void Program::Load(string)

    ldstr      "ContravariantSZArraySZArray"
    call       void Program::Load(string)

    ldstr      "ContravariantDerivedCB"
    call       void Program::Load(string)

    ldstr      "ContravariantDerivedCA"
    call       void Program::Load(string)

    ldstr      "ContravariantICB"
    call       void Program::Load(string)

    ldstr      "ContravariantICA"
    call       void Program::Load(string)

    ldstr      "ContravariantStructIA"
    call       void Program::LoadThrowsTypeLoadException(string)

    ret
  }

    .method private static void GenericParameterConstraint() {

    // virtual explicit
    ldstr      "MethodConstraintWeaker"
    call       void Program::Load(string)

    ldstr      "MethodConstraintWeakest"
    call       void Program::Load(string)

    ldstr      "MethodConstraintStrongAgain"
    call       void Program::LoadThrowsTypeLoadException(string)

    // virtual implicit
    ldstr      "MethodConstraintImplicitWeaker"
    call       void Program::Load(string)

    ldstr      "MethodConstraintImplicitWeakest"
    call       void Program::Load(string)

    ldstr      "MethodConstraintImplicitStrongAgain"
    call       void Program::LoadThrowsTypeLoadException(string)

    ldstr      "MethodConstraintImplicitStrongerAgain"
    call       void Program::LoadThrowsTypeLoadException(string)

    // interface explicit
    ldstr      "MethodIConstraintWeaker"
    call       void Program::Load(string)

    ldstr      "MethodIConstraintWeakest"
    call       void Program::Load(string)

    // interface implicit
    ldstr      "MethodIConstraintImplicitWeaker"
    call       void Program::Load(string)

    ldstr      "MethodIConstraintImplicitWeakest"
    call       void Program::Load(string)

    ldstr      "MethodIConstraintImplicitStrongAgain"
    call       void Program::LoadThrowsTypeLoadException(string)

    ldstr      "MethodIConstraintImplicitStrongerAgain"
    call       void Program::LoadThrowsTypeLoadException(string)

    ret
  }

  .method private static void BadTypeLoadException() {

    //ldstr      "StrongerConstraint"
    //call       void Program::LoadThrows(string)

    ret
  }
  
  .method private static void  LoadThrowsTypeLoadException(string name) cil managed
  {
    .try
    {
      ldarg.0
      call       void Program::Load(string)
      leave.s    FAIL
    }
    catch [mscorlib]System.TypeLoadException 
    {
      pop
      leave.s    OK
    }

    FAIL:  
    ldarg.0
    newobj     instance void [mscorlib]System.Exception::.ctor(string)
    throw

    OK:  
    ret
  } 

  .method private static void  LoadThrowsMissingMethodException(string name) cil managed
  {
    .try
    {
      ldarg.0
      call       void Program::Load(string)
      leave.s    FAIL
    }
    catch [mscorlib]System.MissingMethodException 
    {
      pop
      leave.s    OK
    }

    FAIL:  
    ldarg.0
    newobj     instance void [mscorlib]System.Exception::.ctor(string)
    throw

    OK:  
    ret
  } 

  .method private static void Load(string name) cil managed
  {
    ldarg.0
    call       class [mscorlib]System.Type [mscorlib]System.Type::GetType(string)
    pop
    ret
  }
} 
