use std::io::{Read, Write};
use std::process::{Command, Stdio};

pub mod diagnostic {
    include!(concat!(env!("OUT_DIR"), "/diagnostic.rs"));
}

use diagnostic::{Diagnostic, DiagnosticRequest, DiagnosticResponse, Severity};
use prost::Message;

fn write_message<M: Message>(stream: &mut impl Write, message: &M) -> std::io::Result<()> {
    let payload = message.encode_to_vec();
    let len = payload.len() as u32;
    stream.write_all(&len.to_be_bytes())?;
    stream.write_all(&payload)?;
    stream.flush()
}

fn read_message<M: Message + Default>(stream: &mut impl Read) -> std::io::Result<M> {
    let mut len_buf = [0u8; 4];
    stream.read_exact(&mut len_buf)?;
    let len = u32::from_be_bytes(len_buf) as usize;
    let mut payload = vec![0u8; len];
    stream.read_exact(&mut payload)?;
    M::decode(payload.as_slice())
        .map_err(|e| std::io::Error::new(std::io::ErrorKind::InvalidData, e))
}

fn main() -> std::io::Result<()> {
    let mut child = Command::new("python3")
        .arg("../server.py")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    let mut stdin = child.stdin.take().expect("server stdin");
    let mut stdout = child.stdout.take().expect("server stdout");

    let request = DiagnosticRequest {
        file: "danger.fish".to_string(),
        contents: "echo hello\nrm -rf $HOME\necho done\n".to_string(),
    };
    write_message(&mut stdin, &request)?;

    let response: DiagnosticResponse = read_message(&mut stdout)?;
    println!("{response:#?}");

    let expected = Diagnostic {
        file: "danger.fish".to_string(),
        line: 2,
        severity: Severity::Error as i32,
        message: "refusing to bless bare rm -rf".to_string(),
    };
    assert_eq!(response.diagnostics.len(), 1, "expected exactly one diagnostic");
    assert_eq!(response.diagnostics[0], expected, "diagnostic content mismatch");
    println!("cross-language round-trip OK: rust client <-> python server");

    drop(stdin);
    child.wait()?;
    Ok(())
}
