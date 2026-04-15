terraform {
    backend "gcs"{
        bucket = "tf-state-landing-zafa"
        prefix = "host"
    }
}