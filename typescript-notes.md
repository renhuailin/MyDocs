Typescript Notes
--------------

# What's new? 

2.6  https://blogs.msdn.microsoft.com/typescript/2017/10/31/announcing-typescript-2-6/

# 语法

## TypeScript (Three dots)三个点语法
TypeScript 中的三个点语法是指 Rest Parameters、Spread Operators 和 Destructuring。
下面分别介绍一下它们的用法。

### 1. Rest Parameters
Rest Parameters 是用来表示一个函数可以接受不定数量的参数。它用三个点（...）加上一个参数名来表示，这个参数将会是一个数组，包含了所有传入的参数。

例如：
```ts
function foo(...args: number[]) {
  console.log(args);
}

foo(1, 2, 3); // 输出 [1, 2, 3]
foo(4, 5); // 输出 [4, 5]
```
### 2.Spread Operators
Spread Operators 是用来将数组或对象展开成一个新的数组或对象。它也用三个点（...）来表示。

例如：
```ts
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];
const arr3 = [...arr1, ...arr2];

console.log(arr3); // 输出 [1, 2, 3, 4, 5, 6]
```

还可以使用 Spread Operators 将一个对象的属性展开到另一个对象中：
```ts
const obj1 = { foo: 1, bar: 2 };
const obj2 = { ...obj1, baz: 3 };

console.log(obj2); // 输出 { foo: 1, bar: 2, baz: 3 }
```
### 3. Destructuring
Destructuring 是一种将数组或对象的属性解构成独立变量的语法。它也用三个点（...）来表示。当三个点（...）和解构语法一起使用时，它表示剩余的所有属性或元素。

例如：
```ts
const arr = [1, 2, 3, 4, 5];
const [first, second, ...rest] = arr;

console.log(first); // 输出 1
console.log(second); // 输出 2
console.log(rest); // 输出 [3, 4, 5]

const obj = { foo: 1, bar: 2, baz: 3 };
const { foo, ...rest } = obj;

console.log(foo); // 输出 1
console.log(rest); // 输出 { bar: 2, baz: 3 }
```


## Interface

在ts里，接口可以继承自类

```typescript
interface Point3d extends Point {
    z: number;
}
```


### import type语法
TypeScript 的 `import type` 语法一种特殊的类型导入方式。

1. 基本含义：
```typescript
import type { User } from './app/lib/definitions';
```
- 仅导入类型定义，不导入值
- 在编译后的 JavaScript 代码中会被完全移除
- User 只能用于类型注解，不能用于运行时逻辑

2. 与普通 import 的区别：

```typescript
// 普通导入（可用于运行时）
import { User } from './definitions';

// 类型导入（仅用于类型检查）
import type { User } from './definitions';
```

3. 使用场景示例：
```typescript
// definitions.ts
export interface User {
    id: number;
    name: string;
    email: string;
}

// 使用类型
import type { User } from './definitions';

// 用于类型注解
const user: User = {
    id: 1,
    name: 'John',
    email: 'john@example.com'
};

// 用于函数参数类型
function updateUser(userData: User) {
    // ...
}
```

4. 为什么使用 import type：
- 更清晰地表明导入的是类型而非值
- 帮助优化打包大小（类型导入会在编译时被移除）
- 避免可能的运行时开销
- 防止意外使用类型作为值

5. 相关语法变体：
```typescript
// 单个类型导入
import type { User } from './definitions';

// 多个类型导入
import type { User, Post, Comment } from './definitions';

// 导入所有类型
import type * as Types from './definitions';

// 重命名类型导入
import type { User as UserType } from './definitions';
```

下面通过示例说明 `import type` 的类型和运行时的区别：

1. 正确用法（类型注解）：
```typescript
import type { User } from './definitions';

// ✅ 作为类型注解
const user: User = {
    id: 1,
    name: 'John'
};

// ✅ 作为函数参数类型
function processUser(user: User) {
    console.log(user.name);
}

// ✅ 作为返回值类型
function getUser(): User {
    return { id: 1, name: 'John' };
}

// ✅ 作为泛型约束
function getUserById<T extends User>(data: T) {
    return data;
}
```

2. 错误用法（运行时逻辑）：
```typescript
import type { User } from './definitions';

// ❌ 不能用作构造函数
const user = new User();  // 错误：'User' 仅表示类型，但在此处作为值使用

// ❌ 不能用作运行时类型检查
if (someObject instanceof User) {  // 错误：'User' 仅表示类型，但在此处作为值使用
    // ...
}

// ❌ 不能用作对象属性访问
console.log(User.prototype);  // 错误：'User' 仅表示类型，但在此处作为值使用

// ❌ 不能解构或使用类型作为值
const { id, name } = User;  // 错误：'User' 仅表示类型，但在此处作为值使用
```

3. 对比普通导入：
```typescript
// definitions.ts
export class User {
    id: number;
    name: string;
    
    constructor(id: number, name: string) {
        this.id = id;
        this.name = name;
    }
}

// 普通导入（可以用于运行时）
import { User } from './definitions';
const user = new User(1, 'John');  // ✅ 正确

// 类型导入（只能用于类型检查）
import type { User } from './definitions';
const user = new User(1, 'John');  // ❌ 错误
```

4. 实际应用场景：
```typescript
// 分离类型和实现
import type { User } from './types';  // 只导入类型
import { createUser } from './services';  // 导入实际功能

async function handleUserRegistration(userData: User) {  // User 作为类型注解
    try {
        const newUser = await createUser(userData);
        return newUser;
    } catch (error) {
        throw new Error('Registration failed');
    }
}
```

5. 混合使用示例：
```typescript
// 同时需要类型和值的情况
import { UserService } from './services';  // 导入服务类
import type { User } from './types';  // 只导入类型

class CustomUserService extends UserService {
    async getUsers(): Promise<User[]> {  // User 作为类型注解
        return await this.fetchUsers();
    }
}
```

6. 类型工具使用：
```typescript
import type { User } from './types';

// ✅ 正确：用于类型操作
type PartialUser = Partial<User>;
type UserKeys = keyof User;
type UserWithExtra = User & { extra: string };

// ❌ 错误：不能用于运行时计算
const userKeys = Object.keys(User);  // 错误：User 只是类型
```

这种区分帮助我们：
- 保持类型定义和运行时代码的清晰分离
- 避免意外使用类型作为值
- 优化编译输出（类型导入会在编译时被完全移除）
- 提高代码的可维护性




## The `satisfies` Operator satisfies操作符

TypeScript 开发人员经常面临一个困境：我们希望确保某些表达式与某些类型 _匹配_，但又希望保留该表达式的 _最具体_ 类型以用于推理目的。

新的`satisfies`运算符让我们可以验证表达式的类型是否与某种类型匹配，而无需更改该表达式的结果类型。例如，我们可以使用`satisfies`来验证`palette`的所有属性是否与`string | number[]`兼容。 `string | number[]` ：

```ts
type Colors = "red" | "green" | "blue";

type RGB = [red: number, green: number, blue: number];

const palette = {

red: [255, 0, 0],

green: "#00ff00",

bleu: [0, 0, 255]

// ~~~~ The typo is now caught!

} satisfies Record<Colors, string | RGB>;

// toUpperCase() method is still accessible!

const greenNormalized = palette.green.toUpperCase();
```     


基本用法

1. 类型检查但保留字面量类型：

```typescript
// 使用 satisfies
const palette = {
    red: [255, 0, 0],
    green: '#00ff00',
} satisfies Record<string, string | number[]>;

palette.red[0]    // 正确：类型是 number
palette.green.toUpperCase()  // 正确：类型是 string
```

2. 不使用 satisfies 的问题：

```typescript
// 使用常规类型注解
const palette: Record<string, string | number[]> = {
    red: [255, 0, 0],
    green: '#00ff00',
};

palette.red[0]    // 错误：不能确定是否为数组
palette.green.toUpperCase()  // 错误：不能确定是否为字符串
```

## Record
Record是TypeScript中的一个实用工具类型，用于创建一个对象类型，其属性键为K，属性值为T。

一、基本语法
```typescript
Record<Keys, Type>
```

二、基础用法示例

1. 简单对象类型：
```typescript
// 创建一个所有属性值都是string的对象类型
type StringRecord = Record<string, string>;

const userInfo: StringRecord = {
    name: "John",
    email: "john@example.com",
    // age: 25  // 错误：值必须是string
};
```

2. 使用联合类型作为键：
```typescript
type UserRole = "admin" | "user" | "guest";
type RoleAccess = Record<UserRole, boolean>;

const access: RoleAccess = {
    admin: true,
    user: true,
    guest: false
    // other: true  // 错误：不允许其他键
};
```

三、高级用法

1. 嵌套Record：
```typescript
type NestedConfig = Record<string, Record<string, number>>;

const config: NestedConfig = {
    database: {
        port: 5432,
        timeout: 1000
    },
    server: {
        port: 8080,
        maxConnections: 1000
    }
};
```

2. 与其他类型组合：
```typescript
type User = {
    id: number;
    name: string;
};

type UsersById = Record<number, User>;

const users: UsersById = {
    1: { id: 1, name: "John" },
    2: { id: 2, name: "Jane" }
};
```

四、实际应用场景

1. API响应缓存：
```typescript
interface ApiCache {
    data: any;
    timestamp: number;
}

type ApiCacheStore = Record<string, ApiCache>;

const cache: ApiCacheStore = {
    "/users": {
        data: [],
        timestamp: Date.now()
    },
    "/posts": {
        data: [],
        timestamp: Date.now()
    }
};
```

2. 状态管理：
```typescript
type LoadingState = "idle" | "loading" | "success" | "error";
type AsyncState = Record<string, LoadingState>;

const pageLoadingState: AsyncState = {
    userProfile: "loading",
    posts: "success",
    comments: "idle"
};
```

3. 配置对象：
```typescript
type Config = Record<string, string | number | boolean>;

const appConfig: Config = {
    apiUrl: "https://api.example.com",
    timeout: 5000,
    enableCache: true,
    maxRetries: 3
};
```

五、与映射类型结合

1. 创建可选属性：
```typescript
type PartialRecord<K extends keyof any, T> = Partial<Record<K, T>>;

type OptionalConfig = PartialRecord<string, number>;

const config: OptionalConfig = {
    timeout: 1000
    // 所有属性都是可选的
};
```

2. 只读属性：
```typescript
type ReadonlyRecord<K extends keyof any, T> = Readonly<Record<K, T>>;

const constants: ReadonlyRecord<string, number> = {
    MAX_RETRY: 3,
    TIMEOUT: 5000
};
// constants.MAX_RETRY = 4;  // 错误：只读属性
```

需要更多特定场景的示例吗？


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



TypeScript 3.5 中，lib.d.ts 内置了一个 `Omit type`，并且可以在任何地方使用，开发者不再需要自己编写。

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
