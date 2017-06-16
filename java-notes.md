要好好了解java 8里的 Predicate，Function,Consumer这几个类，跟lambda有关。



有了缺省方法的interface与abstract class有什么区别？？

Supplier这个东西是干什么的？

# Spring
Spring boot是可以写web的，请看：https://stormpath.com/blog/build-spring-boot-spring-security-app

http://docs.spring.io/spring-boot/docs/1.4.2.RELEASE/reference/htmlsingle/#boot-features-developing-web-applications


Spring的BOM
Maven "Bill Of Materials" Dependency
``` xml
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
``` xml
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
``` xml
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

``` java
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
``` java
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


# Maven
###【常用maven命令】
	mvn archetype:generate
	mvn archetype:generate -DgroupId=com.chinaops -DartifactId=CloudOps -DarchetypeArtifactId=maven-archetype-gwt

$ mvn archetype:generate -DgroupId=com.vianet -DartifactId=ManrecaServer -DarchetypeArtifactId=maven-archetype-quickstart

	mvn archetype:generate -DgroupId=com.chinaops.tuts -DartifactId=Tuts -DarchetypeArtifactId=maven-archetype-webapp

mvn archetype:create -DarchetypeGroupId=com.totsp.gwt \
    -DarchetypeArtifactId=maven-googlewebtoolkit2-archetype \
    -DarchetypeVersion=1.0.4 \
    -DremoteRepositories=http://gwt-maven.googlecode.com/svn/trunk/mavenrepo \
    -DgroupId=com.chinaops \
    -DartifactId=CloudOps
    
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
$ mvn -X archetype:generate -DgroupId=cn.com.xiangcloud -DartifactId=xiangcloud-common -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeCatalog=internal

如果出现问题，请加`-X`用来调试。

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
``` java
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

``` java
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
Liquibase



Hotswap Agent project : http://hotswapagent.org/

Dynamic Source Lookup plugin for Eclipse : https://github.com/ifedorenko/com.ifedorenko.m2e.sourcelookup


Wiremock 用来mock一些api，主要用来测试。

阿里的RPC框架 [dubbo](http://dubbo.io/)

https://yq.aliyun.com/articles/60789

# Logging 
如何live reload log4j configuration.
http://stackoverflow.com/a/4599083


# IDEA spring boot & spring Loaded
首先要设计项目自动编译

设置里：
Build > Compiler > Build project automatically.

然后在启动参数里添加

``` xml
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


