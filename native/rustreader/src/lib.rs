#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

rustler::init!("Elixir.Rustreader", [add]);


use extractous::Extractor;
use rustler::{Encoder, Env, NifResult, Term};

#[rustler::nif(schedule = "DirtyCpu")]
fn extract_pdf(path: String) -> NifResult<(String, String)> {
    let extractor = Extractor::new();

    match extractor.extract_file_to_string(&path) {
        Ok((content, metadata)) => Ok((content, format!("{:?}", metadata))),
        Err(e) => Err(rustler::Error::Term(Box::new(format!("Extraction failed: {}", e))))
    }
}

rustler::init!("Elixir.RustReader", [extract_pdf]);