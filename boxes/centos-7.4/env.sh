tee >> ~/.bash_profile << EOF
export JAVA_HOME=/usr/local/java/jdk1.8.0_144
export MVN_HOME=/usr/local/apache-maven-3.3.9
export PATH=\$JAVA_HOME/bin:\$MVN_HOME/bin:\$PATH
EOF
source ~/.bash_profile