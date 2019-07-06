# Java Notes

## Java 1.8

要好好了解java 8里的 Predicate，Function,Consumer这几个类，跟lambda有关。

mac下找java home

运行： `/usr/libexec/java_home`

有了缺省方法的interface与abstract class有什么区别？？

Supplier这个东西是干什么的？

# jdk 1.4

NIO  这篇文章讲得最好： https://www.ibm.com/developerworks/cn/education/java/j-nio/j-nio.html

JDK1.5_update10版本使用epoll替代了传统的select/poll，极大的提升了NIO通信的性能。

# Spring

Spring boot是可以写web的，请看：https://stormpath.com/blog/build-spring-boot-spring-security-app

http://docs.spring.io/spring-boot/docs/1.4.2.RELEASE/reference/htmlsingle/#boot-features-developing-web-applications

Spring的BOM
Maven "Bill Of Materials" Dependency

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-framework-bom</artifactId>
            <version>5.0.0.M3</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

加了这个依赖后，会强制保证spring的所有的spring dependencies are at the version.  and you no long need to verify the `<version>` attribute when depending on Spring Framework artifacts.

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-web</artifactId>
    </dependency>
<dependencies>
```

Spring的配置已经可以不用xml了，现在大家都用Java-Based configuration.  `@Configuration` ,`@Bean` ,`@Import`,`@DependOn` annotations.

我们引用Spring时会看到很多版本,snapshot结尾的，M结尾的，GA的，一定要用GA的，不要追求新版本。

Spring Framework 4.0 is now focused primarily on Servlet 3.0+ environments. If you are using the Spring MVC Test Framework you will need to ensure that a Servlet 3.0 compatible JAR is in your test classpath.

引入`spring-websocket`  可以实现websocket了。

新的`SocketUtils` enables you scan for free TCP and UDP server ports on localhost.

`org.springframework.mock.web` 现在 now based on Servlet 3.0 API.

The interface `org.springframework.context.ApplicationContext` represents the Spring IoC container.

bean可以设置别名。 

```xml
<alias name="fromName" alias="toName"/>
```

### Spring boot

@RestController  可以直接让Controller输出json

搞定spring boot与alibaba dubbo的整合！昨天的问题找到了，是因dubbo依赖了spring 2.5.6,把它从pom里`exclusions`就可以了。

Change the embedded tomcat http port.
http://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#howto-change-the-http-port

在做Spring boot的junit test时报错：

```
java.lang.IllegalArgumentException: URI is not absolute
```

测试代码是这样的：

```java
/**
 * Created by harley on 12/22/16.
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = OpenApiGateway.class)
@WebIntegrationTest({"server.port=0", "management.port=0"})
public class RequestValidationTest {
    RestTemplate template = new TestRestTemplate();

    @Test
    public void testRequest() {
        String body = this.template.getForObject("/instances", String.class);
        System.out.println(body);
    }
}
```

"/instances"肯定不是个绝对地址啊,而且端口是随机的，所以也无法拼出一个完整的URI。

通过下面的blog，知道了如何注入端口号。
https://blog.jayway.com/2014/07/04/integration-testing-a-spring-boot-application/

修改后的代码如下：

```java
/**
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = OpenApiGateway.class)
@WebIntegrationTest({"server.port=0", "management.port=0"})
public class RequestValidationTest {
    RestTemplate template = new TestRestTemplate();

    @Value("${local.server.port}")
    private int port;

    @Test
    public void testRequest() {
        String body = this.template.getForObject("http://127.0.0.1:" + port +"/instances", String.class);
        System.out.println(body);
    }
}
```

JPA Many to one mapping.
https://hellokoding.com/jpa-one-to-many-relationship-mapping-example-with-spring-boot-maven-and-mysql/

http://stackoverflow.com/a/22307705

### 当打包成Fat Jar时，如何在配置application.properties

生产环境与开发环境的配置经常是不同的，但是打包成Fat Jar时，我们如何修改配置呢？

根据[spring boot reference](http://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html)，是可以把配置外部化的。

```
java -Dspring.config.location=/target/application.properties -jar target/myproject-0.0.1-SNAPSHOT.jar
```

# Maven

###【常用maven命令】
    mvn archetype:generate
    mvn archetype:generate -DgroupId=com.chinaops -DartifactId=CloudOps -DarchetypeArtifactId=maven-archetype-gwt

$ mvn archetype:generate -DgroupId=com.vianet -DartifactId=ManrecaServer -DarchetypeArtifactId=maven-archetype-quickstart

    mvn archetype:generate -DgroupId=com.chinaops.tuts -DartifactId=Tuts -DarchetypeArtifactId=maven-archetype-webapp

mvn archetype:create -DarchetypeGroupId=com.totsp.gwt \
​    -DarchetypeArtifactId=maven-googlewebtoolkit2-archetype \
​    -DarchetypeVersion=1.0.4 \
​    -DremoteRepositories=http://gwt-maven.googlecode.com/svn/trunk/mavenrepo \
​    -DgroupId=com.chinaops \
​    -DartifactId=CloudOps

#### 把本地包加入的本地库中

mvn install:install-file \
  -Dfile=/Users/harley/Downloads/typica-m4c-1.6.jar \
  -DgroupId=china-ops \
  -DartifactId=ecloud-typica \
  -Dversion=1.6 \
  -Dpackaging=jar \
  -DgeneratePom=true

Print dependency tree.
mvn dependency:tree

如果mvn archetype:generate卡住了，增加参数-DarchetypeCatalog=internal后解决卡住问题。

```
$ mvn -X archetype:generate -DgroupId=cn.com.xiangcloud -DartifactId=xiangcloud-common -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeCatalog=internal
```

如果出现问题，请加`-X`用来调试。

## Create a new ArcheType

https://maven.apache.org/guides/mini/guide-creating-archetypes.html

```
mvn archetype:create-from-project -Darchetype.filteredExtensions=java

cd target/generated-sources/archetype/

mvn install

mvn archetype:generate -DarchetypeCatalog=local
```

# 工具备注

##### Java性能总览

最流行的：VisualVM

次流行的：No profiler

模拟 
最流行的：Mockito

最受欢迎的Java模拟测试框架。

自动化Web浏览测试 

最流行的：Selenium

Selenium只是自动化浏览测试。开发者经常使用这个工具配合其他的测试框架，来测试大型Web应用。

**GraalVM**:  可以把java的代码编码成本地代码，这个有点厉害了。

* [这个blog](https://royvanrijn.com/blog/2018/09/part-2-native-microservice-in-graalvm/)讲了如何使用GraalVM+SpringBoot来实现一个native的微服务。

* [这个](https://medium.com/graalvm/instant-netty-startup-using-graalvm-native-image-generation-ed6f14ff7692)是把Netty的应用编译成了native image.

https://medium.com/graalvm/instant-netty-startup-using-graalvm-native-image-generation-ed6f14ff7692

GraalVM native image实现的原理是用 Substrate VM 来编译java,这个vm会被打包进native的二进制可执行文件里。由它来负责内存的相关的管理。

这个pdf讲了它的https://www.oracle.com/technetwork/java/jvmls2015-wimmer-2637907.pdf

```
Substrate VM is …
an embeddable VM
for, and written in, a subset of Java
optimized to execute Truffle languages
ahead-of-time compiled using Graal
integrating with native development tools.
```

### 【What's new in Java 7 & 8 】

[A look at Java 7's new features] (http://radar.oreilly.com/2011/09/java7-features.html)

[10 JDK 7 Features to Revisit, Before You Welcome Java 8](http://www.javacodegeeks.com/2014/04/10-jdk-7-features-to-revisit-before-you-welcome-java-8.html)

java 7的 可以自动关闭资源了:
[The try-with-resources Statement](https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html)

这个非常好，而且作者一直在更新：[Java 8 Features – The ULTIMATE Guide](http://www.javacodegeeks.com/2014/05/java-8-features-tutorial.html)

[What's New in JDK 8](http://www.oracle.com/technetwork/java/javase/8-whats-new-2157071.html)

What's New in Java 8 [https://leanpub.com/whatsnewinjava8/read#leanpub-auto-optional](https://leanpub.com/whatsnewinjava8/read#leanpub-auto-optional) 这个讲得真不错,尤其是streaming部分讲得挺详细的。

[What’s New in Java 8: Lambdas](http://radar.oreilly.com/2014/04/whats-new-in-java-8-lambdas.html)  这个作者的[其它文章](http://radar.oreilly.com/madhusudhank)也很好。

# java 日期

Joda-Time 在java 8之前是java 8之前事实上的data time标准库？（靠，我居然没用过）。Java 8的New Date Time API受其严重启发而生。

得到系统的Zone

```java
System.out.println(ZoneId.systemDefault().toString());
System.out.println("ldt " + LocalDateTime.now().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());

//LocalDateTime to ISO 8601
DateTimeFormatter formatter = DateTimeFormatter.ISO_INSTANT;
System.out.println(formatter.format(LocalDateTime.now().atZone(ZoneId.systemDefault()).toInstant()));

//Parse ISO 8601
ZonedDateTime zonedDateTime = ZonedDateTime.parse("2013-08-27T14:30:10Z");
System.out.println(zonedDateTime.toString());
System.out.println(zonedDateTime.toInstant().getEpochSecond());
System.out.println(zonedDateTime.toInstant().toEpochMilli());

//Convert java.util.Date to LocalDateTime
Date in = new Date();
LocalDateTime ldt = LocalDateTime.ofInstant(in.toInstant(), ZoneId.systemDefault());
Date out = Date.from(ldt.atZone(ZoneId.systemDefault()).toInstant());


//当前时间加一个月
LocalDateTime superBowlXLV = LocalDateTime.of(2011, Month.FEBRUARY, 6,
            0, 0);
LocalDateTime sippinFruityDrinksInMexico = superBowlXLV.plusMonths(1);
```

要看看这个包java.util.function

Method References ，只要是参数类型一样，返回结果兼容，就可以用。方法名可以不一样，有点像函数指针。但是对constructor的引用有点不一样。

## Stream

stream to List

```java
List<Person> filtered =
    persons
        .stream()
        .filter(p -> p.name.startsWith("P"))
        .collect(Collectors.toList());
```

# Spring Data JPA

可以用JPA Tools来生成 entity class.  用eclipse. http://shengwangi.blogspot.com/2014/12/how-to-create-java-classes-from-tables.html

The Java Persistence Query Language
http://docs.oracle.com/javaee/6/tutorial/doc/bnbtg.html

# Others

eclipse 换行插件

http://dev.cdhq.de/eclipse/word-wrap/

JRebel or Spring Loaded  
Thymeleaf

Liquibase 类似于Rails Migration的东西。请见下面的具体章节。

Jtwig   这个模板系统很强，而且能在Spring里使用。推荐。

Hotswap Agent project : http://hotswapagent.org/  这个是用DCEVM的，实现的是jvm级的reload，比Spring loaded更强。

我现在用的就是Hotswap Agent 的JDK。

Dynamic Source Lookup plugin for Eclipse : https://github.com/ifedorenko/com.ifedorenko.m2e.sourcelookup

Wiremock 用来mock一些api，主要用来测试。

阿里的RPC框架 [dubbo](http://dubbo.io/)

https://yq.aliyun.com/articles/60789

# Logging

如何live reload log4j configuration.
http://stackoverflow.com/a/4599083

# Liquibase 数据库变更管理工具

Liquibase
Rails的Db Migration的java alternative.

开发过程中，可以使用命令行来migrate，生产环境用servlet listener的来自动运行，这样的缺点是每次启动时都要运行这个，如果不小心修改了changelog文件，可能会有风险。

# IDEA spring boot & spring Loaded

首先要设计项目自动编译

设置里：
`Build > Compiler > Build project automatically`.

然后在启动参数里添加

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <jvmArguments>
            -javaagent:/Users/harley/.m2/repository/org/springframework/springloaded/1.2.6.RELEASE/springloaded-1.2.6.RELEASE.jar -noverify
        </jvmArguments>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>repackage</goal>
            </goals>
        </execution>
    </executions>

</plugin>
```

# Netty

http://www.infoq.com/cn/articles/netty-high-performance   这里面讲了Reactor主从多线程模型，非常好。

# Eclipse

I installed two Java vm on my mac ,one is  oracle java 1.8 and the other is  dcevm.  Today I download the newest eclipse , but i can not startup  with error "Failed to create java virtual machine".  I googled and try all solution , no help.  I specified the dcevm in `eclipse.ini`   it failed too.   Then I changed jvm to oracle jvm , It started up !

# Mockito

判断http返回值是2xx。

```java
this.mvc.perform(post("/api/cliente/pessoafisica/post")
            .contentType(MediaType.APPLICATION_JSON)
            .content("teste"))
            .andDo(print())
            .andExpect(status().is2xxSuccessful());
```

获取response里的json里的某个字段。

```java
mockMvc.perform(get("/springmvc/api/getUser/{id}", userId))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("id").value(userId))
                .andExpect(jsonPath("name").value(userName))
                .andExpect(jsonPath("password").value(userPassword));
```

有时候我们需要把我们Mock的Service注入到我们要测试的controller里去，下面的链接讲了如何去做这件事。

https://stackoverflow.com/questions/16170572/unable-to-mock-service-class-in-spring-mvc-controller-tests

`@Spy` 用来标识那些不mock的属性，比如我们的controller里有一个OrderManager和ProductManager,我们在测试时希望ProductManager用mock的，但是OrderManager我们希望仍然是@Autowired.那我们在测试类里就要把它加上@Spy这个annotation.

```java
package com.ibm.cloud.fawvw.demo;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ibm.cloud.fawvw.demo.controller.OrderController;
import com.ibm.cloud.fawvw.demo.manager.OrderManager;
import com.ibm.cloud.fawvw.demo.model.Order;
import com.ibm.cloud.fawvw.demo.model.Product;
import com.ibm.cloud.fawvw.demo.service.ProductService;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.Date;

import static org.mockito.Mockito.when;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
//import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class OrderTest {
    @Autowired
    private MockMvc mvc;

    @InjectMocks
    OrderController controllerUnderTest;

    @Autowired
    private ObjectMapper objectMapper;

    @Mock
    ProductService productService;

    @Spy
    @Autowired
    private OrderManager orderManager;

    @Test
    public void testPlaceOrder() throws Exception {

//        ProductService productService = mock(ProductService.class);

        Product product = new Product();
        product.setId(1);
        product.setName("Apple magic mouse");
        product.setPrice(348.00f);
        when(productService.getProductById(1)).thenReturn(product);


        Order order = new Order();
        order.setProductId(1);
        order.setQuantity(2);
        order.setUserId(1);
        order.setCreatedAt(new Date());

        this.mvc.perform(post("/orders", order)
                .contentType(APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(order))
        ).andExpect(status().isOk());
//                .andExpect(content().string("Hello World"));


        this.mvc.perform(get("/orders/get/{id}", 8))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("id").value(8))
                .andExpect(jsonPath("quantity").value(2));

    }


    @Before
    public  void setup() {
        MockitoAnnotations.initMocks(this);

        this.mvc = MockMvcBuilders.standaloneSetup(controllerUnderTest).build();
    }
}
```

如何从MVCMock的jsonPath里返回某个属性的值?

How to retrieve String from  jsonPath in mvcMock? 

https://stackoverflow.com/a/49537158



# Nexus

Nexus里的repo有hosts、proxy、group三种，

hosts就是host在Nexus里的repo，当你运行mvn deploy时，artifact 就会Push到这个repo.



proxy类型

A *proxy repository* is a repository that is linked to a remote repository. Any request for a component is verified against the local content of the proxy repository. If no local component is found, the request is forwarded to the remote repository. The component is then retrieved and stored locally in the repository manager, which acts as a cache. Any future requests for the same component are fulfilled from the local storage, eliminating network bandwidth and time overhead when retrieving the component from the remote repository again



Group类型

A *repository group* is a collection of other repositories, where you can combine multiple repositories of the same format into a single item. This represents a powerful feature of Nexus Repository Manager that lets developers rely on a single URL for their configuration needs. For example, if your group has a Maven Central proxy repository and a hosted repository for 3rd party JARs, these can be combined into a group with one URL for builds.






