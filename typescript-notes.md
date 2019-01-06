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









