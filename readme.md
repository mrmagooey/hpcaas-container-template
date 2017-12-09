# HPCaaS-Container-Template

This is the template to build docker containers for the HPCaaS system.

## Quick Overview of HPCaaS

Start by cloning this repository to your machine, this repository is the template that you will customise with your code.

1. You make the container with this template
1. You run it the code with the orchestrator
    * The container runs locally on your machine, or
    * You have API keys for a supported cloud provider, and container runs on that cloud
1. You get your results 
    * If run on your local machine, the results are copied from the container to a local directory,
    * If run in the cloud, your computer downloads the results

## Developing Your Container
### Adding your Code

Use the docker build options `ADD` or `COPY` to add your code to the container. 

The default executable that the container looks for is called `hpc_code`, and needs copy the entrypoint executable to `/hpcaas/code/hpc_code`. 

Your code may have some dependencies that need to be installed before it can work. If these can be installed via ubuntu repositories, apt is available. Otherwise, this is a normal docker container that you can customise using typical Dockerfile commands (e.g. ADD, RUN).

### Code Parameters

Your code will probably have parameters that it takes to customise how its simulation/algorithm runs. This might include things like: the size of your simulation, the number of entities you simulate, or the accuracy of the code. There are three considerations for code parameters:

1. How to specify what parameters your code takes
1. How the user passes these parameters to your code 
1. How your code picks up these parameters and uses them when it is running in the container

#### Specifying Your Parameters

You specify your codes parameters using a JSON file named `parameters.json` which is located the same directory as this README.md file. This json information is then stored as metadata on the container when it gets built.

The JSON file consists of a single top level object, where every key on the object is the name of a parameter entry and which the value is another object containing parameter properties. The key of each parameter entry will be what is passed to the container and must not have spaces in it.

Each entry in the parameters file must identify what type it is and there are five parameter types each with different usage options:

1. Integer
    * maximum: the maximum value possible for the property (optional property)
    * minimum: the minimum value possible for the property (optional property)
1. Float
    * maximum: the maximum value possible for the property (optional property)
    * minimum: the minimum value possible for the property (optional property)
1. String
    * options: a whitelist of potential strings (optional property)
1. Boolean
1. File
    
Each parameter entry can also have these fields:

1. description: a description of the parameter entry
1. required: whether or not this parameter is required for your code to work (Defaults to false)

Using these types and their options, an example config.json file might look like:

    "parameters": [
        {
            "name": "parameter1",
            "type": "integer",
            "description": "A description of the integer parameter",
            "max": 1000,
            "min": 30,
            "required": true
        },
        {
            "name": "parameter1",
            "type": "float",
            "description": "A description of the float parameter",
            "min": 30.5,
            "required": true
        },
        {
            "name": "parameter1",
            "type": "string",
            "description": "This parameter will take any string"
        },
        {
            "name":"boolean_parameter",
            "type": "boolean",
            "description": "A boolean parameter"
        },
        {
            "name":"file_parameter1",
            "type": "file",
            "description": "A description of the file parameter"
        }
    ]
    
When you build your HPCaaS container, this parameter data will be encoded into the label metadata at `hpcaas.parameters`. 

#### How the User Passes Parameters

This is mostly the job of the HPCaaS orchestrator and container daemon, which, at runtime, will:

1. Fetch the parameter metadata from your container
1. Get valid parameter values from the user
1. Pass these values to the HPCaaS container daemon
1. The container daemon will run your code with these parameters

#### Using Parameters in Your Code

The HPCaaS container daemon is responsible for correctly running your code and ensuring that it receives correct parameters. It will make the parameters available in a number of ways that you as the developer can choose to use.

##### Parameter Environment Variables

Any parameters that your code needs will be be available in environment variables under the prefix `PARAM_`. This means that if your code parameter is called foo, whatever value the user has chosen for foo will be provided to each container under `PARAM_foo`. For file parameters, the value of the environment variable will be an absolute path to the file, which will be stored in the container at `/hpcaas/parameters/files/<filename>`.

Keep in mind that if you choose to get your parameters from environment variables, environment variables are always stored as strings.

##### Parameter Files

In addition to being available as environment variables, parameters will be available in two files:

1. /hpcaas/parameters/parameters.json
1. /hpcaas/parameters/parameters

The first being a flat JSON object containing key-value mappings of the parameters, and the second containing newline separated parameters in the environment variable format (e.g. `foo=bar`). The `PARAM_` prefix is not added to the parameter names in these files. 

In the JSON file the types are preserved (e.g. Number, bool, string), but in the second file all values are strings (again, due to how environment variables work).

### Code Configuration

Your code may have special requirements for its runtime environment. Similar to the code parameters json file, we use a `container_config.json` file (in the same directory as this readme), as the source of configuration information. 

*Code Entry Point*

Currently the container assumes that the entrypoint exectuable for your code is called `hpc_code`. You can customise this by adding:

    {
      codeName: "your_code_name_here",
    }

The container will now try to execute the new name.

*Extra Ports*

If your application needs cluster communication outside of that provided by ssh (which is included by default with every container), then you can request additional open ports between your containers. Because the same network interface can potentially have multiple containers behind it, it is impossible to provide the same port to each container without encountering port collision issues. 

To deal with this issue of port collision, the HPCaaS system lets you request additional ports to be open between containers, which the HPCaaS system will open and populate the containers with this port information. To request extra ports, add an `extraPorts` key to your `container_config.json` file, like so:

    {
      extraPorts: {
        myPort: 2000
      }
    }

This will result in:

1. A random port on the host being mapped to the container port.
1. Each container being given a list of the foreign ports for each container in the cluster.

The list of port mappings for the cluster will be available through the runtime configuration information. In the built container the information will be available from `/hpcaas/runtime/config.json` and will look like:

    {
      extraPorts: {
        myPort: {
          1: "123.123.123.123:40000",
          2: "123.123.123.123:40001"
        }
      }
    }

For `/hpcaas/runtime/config` it will look like:

    EXTRA_PORTS_MYPORT_1: "123.123.123.123:40000"
    EXTRA_PORTS_MYPORT_2: "123.123.123.123:40001"

The list of port mappings for the cluster will be available through the runtime configuration information.

Keep in mind that any ports you open will potentially be open on the wider internet (depending on where your code gets run), so using ssh as much as possible is generally preferable.

*Shared File System*

(To be implemented)

If your container requires a shared filesystem across containers, add to `container_config.json`:

    {
      sharedFileSystem: true,
    }

This will mount a shared file system at `/hpcaas/shared`.

## Metadata

We've described how we use `parameters.json` to describe the parameter information for your code, and how we use `container_config.json` to customise the container environment and services. The final item in the HPCaaS container puzzle is metadata for the container which we store our container metadata in `metadata.json`.

### Naming and tagging

You will probably want to version your container, otherwise the build system will tag your container as unknown/unknown:0.0.0. To tag and name your container add:

    {
      "name": "your_container_name",
      "version": "0.1.1"
    }

### Misc metadata

You can add any other metadata to this file. 

    {
      author: "Itsa me, Mario"
      description: "Container used to test something"
    }

## Building Your Container

You should now have four files in this directory:

1. `parameters.json`: Parameter information that your code requires
1. `container_config.json`: Container environment and metadata
1. `metadata.json`: Metadata for the container
1. `Dockerfile`: Your dockerfile that copies your code and installs your dependencies

...and have your copied code in `./code/`.

You can build the container by running build:

    make

This will generate your HPCaaS container, and save it locally to docker.

To see your new image type `docker images`. To run this image you will need something like hpcaas-orchestrator.

### Runtime Information

There are a number of runtime parameters that the HPCaaS system will make available to your container. These parameters will be made available via environment variables (all uppercase with underscores replacing spaces), and via a pair of config files at `/hpcaas/runtime/config.json` (flat object) and `/hpcaas/runtime/config` (newline separated).

*World Rank*
A unique, monotonically increasing integer ID that is given to each container.

*World Size*
The total number of containers in the cluster.

*Cluster IPs*
A list of the other container IPs in this cluster. There can be less IPs than containers, as some IPs may host multiple containers.

*Cluster SSH Addresses*
A mapping of container world ranks to SSH addresses, i.e. <ip>:<port>. Will be added to `.ssh/config` so that ssh'ing directly to the container name is possible.

### Results

At the end of your code running, it must save its results to `/hpcaas/results`. Once the primary code process ends, the container daemon will upload/copy everything in the results directory to the location specified by the hpcaas-orchestrator.

