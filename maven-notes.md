maven备忘
----------


【常用maven命令】

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
    
# 把本地包加入的本地库中
mvn install:install-file \
  -Dfile=/Users/harley/Downloads/typica-m4c-1.6.jar \
  -DgroupId=china-ops \
  -DartifactId=ecloud-typica \
  -Dversion=1.6 \
  -Dpackaging=jar \
  -DgeneratePom=true
  
  
  
  
mvn dependency:tree