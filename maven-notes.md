maven备忘
----------

【常用maven命令】

```
$ mvn archetype:generate
$ mvn archetype:generate -DgroupId=com.chinaops -DartifactId=CloudOps -DarchetypeArtifactId=maven-archetype-gwt

$ mvn archetype:generate -DgroupId=com.vianet -DartifactId=ManrecaServer -DarchetypeArtifactId=maven-archetype-quickstart
$ mvn archetype:generate -DgroupId=com.chinaops.tuts -DartifactId=Tuts -DarchetypeArtifactId=maven-archetype-webapp

mvn archetype:create -DarchetypeGroupId=com.totsp.gwt \
    -DarchetypeArtifactId=maven-googlewebtoolkit2-archetype \
    -DarchetypeVersion=1.0.4 \
    -DremoteRepositories=http://gwt-maven.googlecode.com/svn/trunk/mavenrepo \
    -DgroupId=com.chinaops \
    -DartifactId=CloudOps
```

如果mvn archetype:generate卡住了，增加参数-DarchetypeCatalog=internal后解决卡住问题。
$ mvn -X archetype:generate -DgroupId=cn.com.xiangcloud -DartifactId=xiangcloud-common -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeCatalog=internal

如果出现问题，请加`-X`用来调试。

```$ mvn clean compile package -Dmaven.test.skip=true```

# 把本地包加入的本地库中

mvn install:install-file \
  -Dfile=/Users/harley/Downloads/typica-m4c-1.6.jar \
  -DgroupId=china-ops \
  -DartifactId=ecloud-typica \
  -Dversion=1.6 \
  -Dpackaging=jar \
  -DgeneratePom=true

mvn dependency:tree

# Create a runnable jar

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-dependency-plugin</artifactId>
    <executions>
        <execution>
            <id>copy-dependencies</id>
            <phase>prepare-package</phase>
            <goals>
                <goal>copy-dependencies</goal>
            </goals>
            <configuration>
                <outputDirectory>
                    ${project.build.directory}/libs
                </outputDirectory>
            </configuration>
        </execution>
    </executions>
</plugin>

<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-jar-plugin</artifactId>
    <configuration>
        <archive>
            <manifest>
                <addClasspath>true</addClasspath>
                <classpathPrefix>libs/</classpathPrefix>
                <mainClass>
                    org.baeldung.executable.ExecutableMavenJar
                </mainClass>
            </manifest>
        </archive>
    </configuration>
</plugin>
```

使用Self-Signed certificate 时，禁用ssl检查

```xml
$ cat ~/.mavenrc 
MAVEN_OPTS="-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true"
```

[Publishing Archetypes](https://books.sonatype.com/mvnref-book/reference/archetype-sect-publishing.html)   这里面讲到了如何在mvn 命令行里导出`archetype-catalog.xml`

使用自定义Nexus里的Archetype

```
$ mvn archetype:generate -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true 
```
