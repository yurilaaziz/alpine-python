## A very minimal python3 docker images based on alpine


## Build image
````bash
make build PYTHON_VERSION=3.6.8 ARCH=amd64
````

## Push image to the registry  
````bash
make publish PYTHON_VERSION=3.6.8 ARCH=amd64
````