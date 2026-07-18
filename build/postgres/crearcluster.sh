echo 'Escriba la ruta del cluster / Write the full path to the cluster:'
read RutaCluster
mkdir "$RutaCluster"
./bin/initdb -D "$RutaCluster" -U postgres -W
