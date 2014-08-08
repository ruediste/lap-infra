#!/bin/bash

cat openjdk.tar.xz | xz -d | tar x

ln -s usr/lib/jvm/java-7-openjdk-amd64/jre/bin/ bin 

# modify path
readlink .bashrc | xargs -IX bash -c "rm .bashrc; cp X .bashrc"
echo "export PATH=/home/core/bin:$PATH" >> .bashrc

# add btrbck launcher
cat > bin/btrbck <<EOF
#!/bin/bash
java -jar /home/core/btrbck.jar \$@
EOF

chmod 755 bin/btrbck