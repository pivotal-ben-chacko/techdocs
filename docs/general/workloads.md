![tap logo](../images/tap.png)

## Sample Workload

A sample Workload for a Spring Boot Java Web application:

**Sample Maven Workload**
```
apiVersion: carto.run/v1alpha1
kind: Workload
metadata:
  name: helloworld
  labels:
    apps.tanzu.vmware.com/workload-type: web
    app.kubernetes.io/part-of: helloworld
    apps.tanzu.vmware.com/language: java
    apps.tanzu.vmware.com/has-tests: "true"
    apps.tanzu.vmware.com/auto-configure-actuators: "true"
spec:
  source:
    git:
      url: https://git-enterprise-jc.onefiserv.net/jmht/jmht-spring-helloworld.git
      ref:
        branch: main
  build:
    env:
    - name: BP_JVM_VERSION
      value: "17"
  env:
    - name: NAME
      value: George
  params:
  - name: testing_pipeline_matching_labels
    value:
      tap.fiserv.com/build-tool: maven
  - name: buildServiceBindings
    value:
    - kind: Secret
      name: settings-xml
  - name: annotations
    value:
      autoscaling.knative.dev/minScale: "1"
  - name: wiz
    value:
      client-id: <wiz-client-id>
      client-secret: <wiz-client-secret>
      use-policy: <wiz-scan-policy>
```
The following sections elaborate on these settings.

## General

### Metadata

**Field**

**Purpose**

name

Name of the workload resource

labels

Labels applied to the workload resource. The following are used to enable specific features:

**Label**

**Purpose**

apps.tanzu.vmware.com/workload-type

Selects the type of the workload (see [Overview of workloads](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/workloads-workload-types.html))

app.kubernetes.io/part-of

(optional) Associates this workload with others

apps.tanzu.vmware.com/language

(optional) Indicates the language used to build this component

apps.tanzu.vmware.com/has-tests

(optional) Indicates the component has tests which should be executed in the supply chain pipeline

apps.tanzu.vmware.com/auto-configure-actuators

(optional) For components using Spring-Boot with Actuator, sets runtime settings to configure the management endpoint (see [https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/spring-boot-conventions-configuring-spring-boot-actuators.html](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/spring-boot-conventions-configuring-spring-boot-actuators.html))

### Spec

**Field**

**Purpose**

source

The location of the component source code (GIT in the example)

build

Build configuration, for the build resources in the supply chain (see [Build Parameters](#WorkingwithJVMWorkloads-build-parameter))

env

Environment variables to be passed to the runtime container (see [Run Parameters](#WorkingwithJVMWorkloads-run-parameters))

params

Additional parameters

See [Workload and Supply Chain Custom Resources](https://cartographer.sh/docs/development/reference/workload/) for the full specification and additional options.

## Build Parameters

The Workload build step(s) use the (Paketo) Java Buildpack (see [Use the Tanzu Java Buildpack](https://docs.vmware.com/en/VMware-Tanzu-Buildpacks/services/tanzu-buildpacks/GUID-java-java-buildpack.html)). This buildpack support builds using Maven, Gradle, Leiningen (Lein) or SBT. Build parameters are (mostly) specified through environment variables:

**Variable**

**Purpose**

BP_JVM_VERSION

JDK/JRE version to use (defaults to latest LTS version available at the time the buildpack was released)

BP_JVM_TYPE

Specifies whether the JRE or JDK is installed in the container runtime (defaults to JRE)

BP_<_tool_>_BUILD_ARGUMENTS

Specifies options to be passed to the build tool.

BP_<_tool_>_ADDITIONAL_BUILD_ARGUMENTS

Specifies additional options to be passed to the build tool.

BP_MAVEN_ACTIVE_PROFILES

For Maven builds, specifies the (maven) profile(s) to be used.

BP_<_tool_>_BUILT_MODULE

In a multi-module build, specifies the module to be used for the runtime artifact.

BP_<_tool_>_BUILT_ARTIFACT

Specifies the specific artifact to be used for the runtime artifact.

BP_<INCLUDE | EXCLUDE>_FILES

Specify files (in addition to the artifact) to be included or excluded from the runtime container.

BP_JVM_JLINK_ENABLED

Enable creation of a custom (typically "minimal") JRE

BP_JVM_JLINK_ARGS

Specifies JLink options

BP_JAVA_APP_SERVER

Indicates to include a Java Application Server (and which one) to use: tomcat, tomee, or liberty.

BPL_JVM_HEAD_ROOM

Configure the percentage of headroom the memory calculator will allocated. Defaults to 0.

BPL_JVM_LOADED_CLASS_COUNT

Configure the number of classes that will be loaded at runtime. Defaults to 35% of the number of classes.

BPL_JVM_THREAD_COUNT

Configure the number of user threads at runtime. Defaults to 250.

BPL_JMX_ENABLED

Configure whether Java Management Extensions (JMX) is enabled. Defaults to false. Set this to true to enable JMX functionality.

BPL_JMX_PORT

Configure the port number for JMX. Defaults to 5000. When running the container, this value should match the port published locally, i.e. for Docker: --publish 5000:5000

BPL_DEBUG_ENABLED

Configure whether remote debugging features are enabled. Defaults to false. Set this to true to enable remote debugging.

BPL_DEBUG_PORT

Configure the port number for remote debugging. Defaults to 8000.

BPL_JFR_ENABLED

Configure whether Java Flight Recording (JFR) is enabled. If no arguments are specified via BPL_JFR_ARGS, the default config args dumponexit=true,filename=/tmp/recording.jfr are added.

BPL_JFR_ARGS

Configure custom arguments to Java Flight Recording, via a comma-separated list, e.g. duration=10s,maxage=1m. If any values are specified, no default args are supplied.

JAVA_TOOL_OPTIONS

Configure the JVM launch flags

<_tool_> indicates the build tool, either Maven, Gradle, Lein, or SBT

In the Fiserv environment, access to public package repositories are generally not permitted. To configure the build to use a private repository (e.g. nexus.onefiserv.net), a service binding to specify the maven settings file must be created in the namespace, and referenced in the workload:

**settings-xml**  Expand source

apiVersion: v1

kind: Secret

metadata:

  name: settings-xml

type: service.binding/maven

stringData:

  type: maven

  settings.xml: |

 ```
apiVersion: v1
kind: Secret
metadata:
  name: settings-xml
type: service.binding/maven
stringData:
  type: maven
  settings.xml: |
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
        <servers>
          <server>
            <id>central</id>
            <username></username>
            <password></password>
          </server>
        </servers>
        <mirrors>
            <mirror>
                <id>central</id>
                <name>Fiserv copy of Maven Central</name>
                <url>https://nexus-ci.onefiserv.net/repository/Maven_Central/</url>
                <mirrorOf>central</mirrorOf>
            </mirror>
        </mirrors>
    </settings>
```
The appropriate credentials (username, password) must be specified, if required. In this example, the <mirror> element specifies the repository to be used in place of the public Maven Central repository. Additional specifications may be included as needed (see [Maven Settings Reference](https://maven.apache.org/settings.html)).

Within the workload, the settings binding is configured for the build using the **buildServiceBindings** parameter (in the _params_ section, see the [Sample Workload](#WorkingwithJVMWorkloads-sample)):

**buildServiceBindings parameter**

  - name: buildServiceBindings

  value:

  - kind: Secret

  name: settings-xml 

## Test Parameters

The Workload test step(s) use a Tekton **Pipeline** resource which must be created in the namespace. The following is a Maven test pipeline specification:

**maven-tekton-pipeline**  Expand source

```
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  labels:
    apps.tanzu.vmware.com/pipeline: test
    tap.fiserv.com/build-tool: maven
  name: maven-tekton-pipeline
spec:
  params:
  - name: source-url
    type: string
  - name: source-revision
    type: string
  tasks:
  - name: test
    params:
    - name: source-url
      value: $(params.source-url)
    - name: source-revision
      value: $(params.source-revision)
    taskSpec:
      metadata: {}
      params:
      - name: source-url
        type: string
      - name: source-revision
        type: string
      spec: null
      steps:
      - image: fmk.nexus-ci.onefiserv.net/fmk/java/openjdk-17-maven:FMK-10-01-23
        name: test
        resources: {}
        script: |-
          mkdir workspace
          cd workspace
          export domain=$(echo $(params.source-url) | sed 's#\./#/#') # Needed to fix source-url
          curl -s $domain | tar -m -xz
          mvn -e test -s /opt/maven/settings.xml
        volumeMounts:
        - mountPath: /opt/maven
          name: settings-xml
          readOnly: true
      volumes:
      - name: settings-xml
        secret:
          secretName: settings-xml
```

Key elements in this specification are:

-   metadata/labels:

**apps.tanzu.vmware.com/pipeline: test** identifies the pipeline as a test pipeline

**tap.fiserv.com/build-tool: maven** identifies the pipeline as appropriate for running tests using maven.

-   image: specifies the image to use to run the tests (in this example, the FMK Maven image)
-   script: the specific steps required to run the tests

-   In the example, the first four lines of the script establish a working directory and pull the source code into the directory (from the location specified by params.source-url)
-   the last line actually executes the maven test goal using the Maven settings mounted as /opt/maven/settings.xml

-   volumeMounts:

Required maven settings (such as the mirror and credentials) are mounted as /opt/maven/settings.xml

-   volumes:

The maven settings are retrieved from the secret specified (settings-xml .. in this example, this is the same service binding secret described in the [Build Parameters](#WorkingwithJVMWorkloads-build-parameter) section).

Within the workload, the test pipeline is configured using the **testing_pipeline_matching_labels** parameter (in the _params_ section, see the [Sample Workload](#WorkingwithJVMWorkloads-sample)):

**testing_pipeline_matching_labels parameter**

  - name: testing_pipeline_matching_labels

  value:

  tap.fiserv.com/build-tool: maven

(Note that the **apps.tanzu.vmware.com/pipeline: test** label is assumed.)

Container Scanning (Wiz)

The Workload image scan step uses a Cartographer **ClusterImageTemplate** resource which must be created in the namespace. The following is the Wiz scanning template:

**wiz-scanner-template**  Expand source

```
apiVersion: carto.run/v1alpha1
kind: ClusterImageTemplate
metadata:
  name: wiz-scanner-template
spec:
  imagePath: .status.scannedImage
  retentionPolicy:
    maxFailedRuns: 10
    maxSuccessfulRuns: 10
  lifecycle: immutable

  healthRule:
    multiMatch:
      healthy:
        matchConditions:
          - status: "True"
            type: ScanCompleted
          - status: "True"
            type: Succeeded
      unhealthy:
        matchConditions:
          - status: "False"
            type: ScanCompleted
          - status: "False"
            type: Succeeded

  params:
    - name: image_scanning_workspace_size
      default: 4Gi
    - name: image_scanning_service_account_scanner
      default: scanner
    - name: image_scanning_service_account_publisher
      default: publisher
    - name: image_scanning_active_keychains
      default: []
    # - name: trivy_db_repository
    #   default: ghcr.io/aquasecurity/trivy-db
    # - name: trivy_java_db_repository
    #   default: ghcr.io/aquasecurity/trivy-java-db
    # - name: registry
    #   default:
    #     server: fmk.nexus-ci.onefiserv.net
    #     repository: platform/tap/workloads

  ytt: |
    #@ load("@ytt:data", "data")

    #@ def merge_labels(fixed_values):
    #@   labels = {}
    #@   if hasattr(data.values.workload.metadata, "labels"):
    #@     labels.update(data.values.workload.metadata.labels)
    #@   end
    #@   labels.update(fixed_values)
    #@   return labels
    #@ end

    #@ def scanResultsLocation():
    #@   return "/".join([
    #@    data.values.params.registry.server,
    #@    data.values.params.registry.repository,
    #@    "-".join([
    #@      data.values.workload.metadata.name,
    #@      data.values.workload.metadata.namespace,
    #@      "scan-results",
    #@    ])
    #@   ]) + ":" + data.values.workload.metadata.uid
    #@ end

    #@ def param(key):
    #@   if not key in data.values.params:
    #@     return None
    #@   end
    #@   return data.values.params[key]
    #@ end

    #@ def maven_param(key):
    #@   if not key in data.values.params["maven"]:
    #@     return None
    #@   end
    #@   return data.values.params["maven"][key]
    #@ end
    
    #@ def wiz_param():
    #@   params = data.values.workload.spec.params
    #@   for i in range(len(params)):
    #@     if "wiz" == params[i].name:
    #@       return params[i].value
    #@     end
    #@   end
    #@   return None
    #@ end

    #@ def correlationId():
    #@   if hasattr(data.values.workload, "annotations") and hasattr(data.values.workload.annotations, "apps.tanzu.vmware.com/correlationid"):
    #@     return data.values.workload.annotations["apps.tanzu.vmware.com/correlationid"]
    #@   end
    #@   if not hasattr(data.values.workload.spec, "source"):
    #@     return ""
    #@   end
    #@   url = ""
    #@   if hasattr(data.values.workload.spec.source, "git"):
    #@     url = data.values.workload.spec.source.git.url
    #@   end
    #@   if hasattr(data.values.workload.spec.source, "image"):
    #@     url = data.values.workload.spec.source.image.split("@")[0]
    #@   end
    #@   if param("maven"):
    #@     url = param("maven_repository_url") + "/" + maven_param("groupId").replace(".", "/") + "/" + maven_param("artifactId")
    #@   end
    #@   return url + "?sub_path=" + getattr(data.values.workload.spec.source, "subPath", "/")
    #@ end

    ---
    apiVersion: app-scanning.apps.tanzu.vmware.com/v1alpha1
    kind: ImageVulnerabilityScan
    metadata:
      labels: #@ merge_labels({ "app.kubernetes.io/component": "image-scan" })
      annotations:
        apps.tanzu.vmware.com/correlationid: #@ correlationId()
        app-scanning.apps.tanzu.vmware.com/scanner-name: Wiz                                                    
      generateName: #@ data.values.workload.metadata.name + "-wiz-scan-"
    spec:
      image: #@ data.values.image
      activeKeychains: #@ data.values.params.image_scanning_active_keychains
      scanResults:
        location: #@ scanResultsLocation()
      workspace:
        size: #@ data.values.params.image_scanning_workspace_size
      serviceAccountNames:
        scanner: #@ data.values.params.image_scanning_service_account_scanner
        publisher: #@ data.values.params.image_scanning_service_account_publisher
      steps:
      - name: wiz-generate-report
        image: fmk.nexus.onefiserv.net/fmk/ext-tools/fmk-dind:FMK-08-16-23
        securityContext:
          privileged: true
          runAsUser: 0
        env:
        - name: WIZ_CLIENT_ID
          value: #@ wiz_param()["client-id"]
        - name: WIZ_CLIENT_SECRET
          value: #@ wiz_param()["client-secret"]
        - name: WIZ_POLICY
          value: #@ wiz_param()["use-policy"]
        script: |-
          echo ############################################################
          echo Initializing container
          dockerd >/dev/null 2>&1 &
          until docker info >/dev/null; do sleep 10; done
          echo Docker ready .. fetching Wiz CLI
          mkdir ~/workspace; cd ~/workspace
          curl -s -o wizcli https://wizcli.app.wiz.io/wizcli
          chmod +x wizcli
          echo Wiz ready .. pulling image
          echo Pulling $(params.image)
          docker pull $(params.image)
          echo Performing Wiz scan
          ./wizcli auth --id $WIZ_CLIENT_ID --secret $WIZ_CLIENT_SECRET
          ./wizcli docker scan --image $(params.image) -p $WIZ_POLICY --detailed > $(params.scan-results-path)/scan.cdx.json
          scan_code=$?
          echo Scan complete
          exit $scan_code





```
Within the workload, the Wiz scanning step configured using the **wiz** parameter (in the _params_ section, see the [Sample Workload](#WorkingwithJVMWorkloads-sample)):

**wiz parameter**

  - name: wiz

  value:

  client-id: <wiz client id>

  client-secret: <wiz client secret>

  use-policy: <policy name>

## Run Parameters

Within the Workload, the following sections configure the running component:

**Section**

**Purpose**

env

Specify environment variables to be set in the running container. For example, in the [Sample Workload](#WorkingwithJVMWorkloads-sample):

**env**

  env:

  - name: NAME

  value: George 

resources

Specify resource requests and limits for the running container.

serviceAccountName

Name of the service account under which to run the container (must be created in the container).

serviceClaims

Service claims to be bound through ServiceBindings

## References

[Deploy an app on Tanzu Application Platform](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/getting-started-deploy-first-app.html)

[Overview of workloads](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/workloads-workload-types.html)

[Create or update a workload](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/cli-plugins-apps-tutorials-create-update-workload.html)

[Workload and Supply Chain Custom Resources](https://cartographer.sh/docs/development/reference/workload/)

[Use the Tanzu Java Buildpack](https://docs.vmware.com/en/VMware-Tanzu-Buildpacks/services/tanzu-buildpacks/GUID-java-java-buildpack.html)

[Liberica JVM Runtime Environment](https://github.com/paketo-buildpacks/bellsoft-liberica)

[Overview of Spring Boot conventions](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/spring-boot-conventions-about.html)
