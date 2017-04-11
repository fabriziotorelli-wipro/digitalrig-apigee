
# ApiGee Server EC2 Eco-system RIGLET Domain

Here the project with the purpose of creating a base, extendable rancher server domain with pipelines on ApiGee RIG Orchestration Server. Development/Study environment.

## Prereqs
* Ansible 2.2+
* AWS CLI with configured creds (`aws configure`)
* Terraform
* knock (v0.7)
* Python packages
    * boto
    * pywinrm
    * six
    * pexpect

## Install
To build the rig on EC2:

0. Configure parameters in `inputs`

    * `tf_config_path`: by default should point to `digital-riglet-instances/rancher.riglet`. If you need to edit this, duplicate it and modify the new file.
    * `region`
    * `ansible-domain`: unique identifier for your riglet, e.g. `<initial><lastname>.rancher.riglet` or `<team name>.rancher.riglet`
    * `dmz-availability-zone` and `internal_availability_zone`: check your region to see what's available. These **must** be different.
    * `internal_keypair` and `keypair`: they are not named the same in each region(!). Create your own with your private key in the AWS EC2 console -> Network and Security -> Key Pairs then add key pair.., please provide a standard name such as : rancher-<initial><lastname>-<region>-keypair (It's suitable to create one key pair with you pubic key and save the name in the inputs file)
    * `ad_password:`: define administrative password for AD and the same you can use to login the OVPN.
    * `edgemicro_org`: <my-organization-here>
    * `edgemicro_env`: <my-environment-here>
    * `edgemicro_user`: <my-apigee-user-here>
    * `edgemicro_pass`: <my-apigee-secret-here>
    * `edgemicro_consumer_credentials`: <my-comma-separated-and column-separated-application-credentials-here>
    * `edgemicro_private_cloud`: <yes-or-not-allowed-for-admins-only>
    * `edgemicro_router`: <apigee-full-qualified-router-url> (ex: http://myorg.myenv.apigee.net)
    * `edgemicro_api_mngmt`: <apigee-full-qualified-api-manager-url> (ex: http://myorg.myenv.apigee.net)

0. Define X509 Certificate keys (for a self-signed server certificate with common name as the `APIGee organization gateway hostname or IP` for defining remote access to Gateway Port Services and another server certificate with `localhost` common name for defining local access to Gateway Index Services), for instance as follow :

## TLS Self-Signed Certificates

##### Generate private key (.key)

```sh
# Key considerations for algorithm "RSA" ≥ 2048-bit
openssl genrsa -out server.key 2048

# Key considerations for algorithm "ECDSA" ≥ secp384r1
# List ECDSA the supported curves (openssl ecparam -list_curves)
openssl ecparam -genkey -name secp384r1 -out server.key
```

##### Generation of self-signed(x509) public key (PEM-encodings `.pem`|`.crt`) based on the private (`.key`)

```sh
openssl req -new -x509 -sha256 -key server.key -out server.pem -days 3650
```

## TLS Self-Signed CA Certificates

##### Generate root key (rootCA.key)

```sh
# Key considerations for algorithm "RSA" ≥ 2048-bit
openssl genrsa -out rootCA.key 2048

#The standard key sizes today are 1024, 2048, and to a much lesser extent, 4096. We choose a very private key.
# It's very important to pay attention to common name, it defines the server who has access to the services
# Common Name (eg, YOUR name) []: 10.0.0.1
openssl genrsa -des3 -out rootCA.key 2048
```

##### The next step is to self-sign this certificate
```sh
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem
```

##### Generate private key (.key)

```sh
# Key considerations for algorithm "RSA" ≥ 2048-bit
openssl genrsa -out server.key 2048

# It's very important to pay attention to common name, it defines the server who has access to the services
# Common Name (eg, YOUR name) []: 10.0.0.1
openssl req -new -key server.key -out server.csr
```

##### Generation of self-signed(x509) public key (PEM-encodings `.pem`|`.crt`) based on the private (`.crs`)

```sh
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 1024 -sha256
```

Remember to store new keys in `vars` file in the located at : `/digital-apigee-riglet/ec2/vars`

0. Execute Terraform (parameters from `input` will be passed to TF)
  `ansible-playbook -i ./inventory/localhost -e @vars -e @inputs -e @private ../tf_run.yml`

0. Generate Ansible var file from TF outputs:
  `ansible-playbook -i ./inventory/localhost -e @inputs -e @vars -e @private ../tf_outputs-minimal.yml`

0. Make sure you're able to open ssh connection to jump host. Command and hostname are the output of "show jump host information" task in the previous step.
   If you can't open ssh connection, please make sure to configure ssh properly. See Troubleshooting section.
   You have to report your AWS API Key/Secret or Token in the just created local folder : digitalrig-rancher-riglet/tmp in order to allow
   Ansible to create contexts and resources under AWS

0. Execute RIG init scripts:
  `ansible-playbook -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml rig.yml`

  If you encounter errors completing this script (it can take a while), consider running each referred script in turn (see `rig.yml`).

0. Once you are done, connect to VPN (check [section 4a on the wiki](https://digitalrig.atlassian.net/wiki/pages/viewpage.action?pageId=54460451)) and run
  `ansible-playbook -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml on_vpn.yml`


0. Now you can deploy Pipelines, run
  `ansible-playbook -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml ./apigee_pipeline.yml`

  *NOTE:* Just 2 pipelines services will autostart, in order to give you the experience to discover the pipeline. At the moment we have just one
  kind of pipeline in the workshop, however this gives you the idea how it works. We have a ApiGee Catalog with multiple pipelines
  at : [Buildit ApiGee Catalog](https://github.com/fabriziotorelli-wipro/buildit-rancher-catalog) and you can set-up it on the ApiGee
  UI at : Admin -> Settings -> Catalog -> Custom -> Add Catalog [Parameters -> Name: BuilditCatalog, URL: https://github.com/fabriziotorelli-wipro/buildit-rancher-catalog.git, Branch: master]


### Troubleshooting
* In case of failure to download some external package:
     * Retry the execution; and
     * Consider adding retry to the step (`until` in ansible task).

* In case of "UNREACHABLE" error during Ansible execution (by default knockd opens SSH access for 60 minutes):

  0. Knock-knock `ansible-playbook -i ./inventory -e @inputs -e @vars ../knocker.yml`
  0. Re-run required step.
* In case ssh to jump host does not work
  * Configure key authentication for VPC subnet `10.10.243.*` mask and jump host by adding following lines to your ~/.ssh/config
  ```bash
  Host 10.10.243.* <<jump.host.name>>
      User centos
      IdentityFile <<path/to/internal/private/key>>
  ```

## Tips
* _-vvvv_ is your friend to understand why your playbook does not work
* It uses mixed dynamic (EC2 tag-based) and static (localhost and group_vars) inventory
* Actual variables `ansible -m setup -i ... host`
* To check ansible registry: `./inventory/ec2.py --list --refresh-cache`

## Destroy

To destroy the infrastructure:

   ```ansible-playbook -i ./inventory/localhost -e @vars -e @inputs -e @private ../tf_destroy.yml```

It will require a yes/no confirmation. As in the actual terraform command, the answer MUST be "yes"
