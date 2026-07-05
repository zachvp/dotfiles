fn main() {
    prost_build::compile_protos(&["../proto/diagnostic.proto"], &["../proto"])
        .expect("failed to compile diagnostic.proto");
}
