Typescript Notes
--------------

# What's new? 

2.6  https://blogs.msdn.microsoft.com/typescript/2017/10/31/announcing-typescript-2-6/





# JSDoc-style

JSDoc-style type annotations : [Get the advantages of TypeScript without transpiling](http://seg.phault.net/blog/2017/10/typescript-without-transpiling/?utm_content=buffer8a673&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer)



# ts-node

```
$tsnode
```

报错了

```
Thrown: ⨯ Unable to compile TypeScript
[eval].ts: Cannot find name 'exports'. (2304)
[eval].ts (0,11): Cannot find name 'module'. (2304)
[eval].ts (1,26): Cannot find module 'moment'. (2307)
```

https://github.com/TypeStrong/ts-node/issues/351#issuecomment-329234952



# Interface

在ts里，接口可以继承自类

```typescript
interface Point3d extends Point {
    z: number;
}
```





# **Omit helper type**

很多时候，我们想要创建一个省略某些属性的对象，TypeScript 内置的 Pick 和 Exclude helper 可以完成类似的功能。例如，如果我们想要定义一个没有 location 属性的 Person，可以编写以下内容：

```typescript
type Person = {
    name: string;
    age: number;
    location: string;
};

type RemainingKeys = Exclude<keyof Person, "location">;

type QuantumPerson = Pick<Person, RemainingKeys>;

// equivalent to
type QuantumPerson = {
    name: string;
    age: number;
};
```



TypeScript 3.5 中，lib.d.ts 内置了一个 Omit type，并且可以在任何地方使用，开发者不再需要自己编写。

让每个人都定义自己的 Omit 版本，TypeScript 3.5将在lib.d.ts中包含它自己的版本，可以在任何地方使用。编译器本身将使用此 Omit type 来表示通过泛型上的对象 rest 析构声明创建的 type。

# **改进了联合 type 中的多余属性检查**

TypeScript 在对象中有一个称为多余属性检查的功能，此功能旨在检测 type 不符合特定属性时的问题。

```typescript
type Style = {
    alignment: string,
    color?: string
};

const s: Style = {
    alignment: "center",
    colour: "grey"
//  ^^^^^^ error! 
};
```

在 TypeScript 3.4 及更早版本中允许某些多余的属性。如下，TypeScript 3.4 允许对象中的 name 属性不正确，即使它的 type 在 Point 和 Label 之间都不匹配。

```typescript
type Point = {
    x: number;
    y: number;
};

type Label = {
    name: string;
};

const thing: Point | Label = {
    x: 0,
    y: 0,
    name: true // uh-oh!
};
```

因为不会对成员进行任何多余的属性检查，所以错误的 name 不会被在意，但在 TypeScript 3.5 中，现在 type 检查器至少会验证所有提供的属性是否属于某个联合成员并具有适当的类型，这意味着上面的示例将会抛出错误。

需要注意的是，只要属性 type 有效，仍允许部分重叠：

```typescript
const pl: Point | Label = {
    x: 0,
    y: 0,
    name: "origin" // okay
};
```



# **泛型构造函数的高阶类型推导**

TypeScript 3.5 中将对泛型构造函数的推导操作整合了起来：

```typescript
class Box<T> {
    kind: "box";
    value: T;
    constructor(value: T) {
        this.value = value;
    }
}

class Bag<U> {
    kind: "bag";
    value: U;
    constructor(value: U) {
        this.value = value;
    }
}


function composeCtor<T, U, V>(
    F: new (x: T) => U, G: new (y: U) => V): (x: T) => V {
    
    return x => new G(new F(x))
}

let f = composeCtor(Box, Bag); // has type '<T>(x: T) => Bag<Box<T>>'
let a = f(1024); // has type 'Bag<Box<number>>'
```

除了上面的组合模式之外，这种对泛型构造函数的新推导意味着在某些 UI 库（如 React）中对类组件进行操作的函数可以更正确地对泛型类组件进行操作。

```typescript
type ComponentClass<P> = new (props: P) => Component<P>;
declare class Component<P> {
    props: P;
    constructor(props: P);
}

declare function myHoc<P>(C: ComponentClass<P>): ComponentClass<P>;

type NestedProps<T> = { foo: number, stuff: T };

declare class GenericComponent<T> extends Component<NestedProps<T>> {
}

// type is 'new <T>(props: NestedProps<T>) => Component<NestedProps<T>>'
const GenericComponent2 = myHoc(GenericComponent);
```

## Smarter union type checking

When checking against union types, TypeScript typically compares each constituent type in isolation. For example, take the following code:

```
type S = { done: boolean, value: number }
type T =
    | { done: false, value: number }
    | { done: true, value: number };

declare let source: S;
declare let target: T;

target = source;
```

Assigning `source` to `target` involves checking whether the type of `source` is assignable to `target`. That in turn means that TypeScript needs to check whether `S`:

```
{ done: boolean, value: number }
```

is assignable to `T`:

```
{ done: false, value: number } | { done: true, value: number }
```

Prior to TypeScript 3.5, the check in this specific example would fail, because `S` isn’t assignable to `{ done: false, value: number }` nor `{ done: true, value: number }`. Why? Because the `done`property in `S` isn’t specific enough – it’s `boolean` whereas each constituent of `T` has a `done` property that’s specifically `true` or `false`. That’s what we meant by each constituent type being checked in isolation: TypeScript doesn’t just union each property together and see if `S` is assignable to that. If it did, some bad code could get through like the following:

```typescript
interface Foo {
    kind: "foo";
    value: string;
}

interface Bar {
    kind: "bar";
    value: number;
}

function doSomething(x: Foo | Bar) {
    if (x.kind === "foo") {
        x.value.toLowerCase();
    }
}

// uh-oh - luckily TypeScript errors here!
doSomething({
    kind: "foo",
    value: 123,
});
```

So clearly this behavior is good for some set of cases. Was TypeScript being helpful in the original example though? Not really. If you figure out the precise type of any possible value of `S`, you can actually see that it matches the types in `T` exactly.

That’s why in TypeScript 3.5, when assigning to types with discriminant properties like in `T`, the language actually *will* go further and decompose types like `S` into a union of every possible inhabitant type. In this case, since `boolean` is a union of `true` and `false`, `S` will be viewed as a union of `{ done: false, value: number }` and `{ done: true, value: number }`.

For more details, you can [see the original pull request on GitHub](https://github.com/microsoft/TypeScript/pull/30779).