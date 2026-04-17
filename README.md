gke-devops-lab
This is a repo for my labatory tests with gcp and terraform. I wanted to test how to deploy infrestructure and manage containers.

The project is just a lab. I was trying to setup a kubernetes autopilot cluster but finaly it was not possible. We ran out of space or quota in the project so the autopilot creation failed everytime. I had to move to a different setup because of that lack of space.

Right now the repo has the terraform files for the network and the gke cluster, and some docker files for a nginx web server.

what i did
setup artifact registry for the images

tryed to fix iam permissions for the nodes

deploy nginx using k8s manifests

I spent a lot of time fixing the 403 forbidden errors when the nodes tryed to pull the image from the registry. Finaly it worked after changing the service account permissions.

notes
The autopilot part is not here because the resource limits. Its a bit anoying but thats how it is. I dont recomend using this for anything serious, its just me leaning how gcp works.

Everything is manual for now until i fix the pipeline.
