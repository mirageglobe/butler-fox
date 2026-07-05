import subprocess
import sys

def run_cmd(args):
    """Helper to run system check and return result."""
    return subprocess.run(
        [sys.executable, 'jsk-system-check.py'] + args,
        capture_output=True,
        text=True
    )

def test_help():
    print("Testing help command...")
    result = run_cmd(['help'])
    assert result.returncode == 0
    assert "jimmy's system check" in result.stdout

def test_version():
    print("Testing version command...")
    result = run_cmd(['version'])
    assert result.returncode == 0
    assert "1.1.0" in result.stdout

def test_check():
    print("Testing check command...")
    result = run_cmd(['check'])
    assert result.returncode == 0
    assert "Operating System :" in result.stdout
    assert "Disk Space:" in result.stdout

def test_applist():
    print("Testing applist command...")
    result = run_cmd(['applist'])
    assert result.returncode == 0
    assert "Common Applications:" in result.stdout

def test_invalid_command():
    print("Testing invalid command...")
    result = run_cmd(['invalid'])
    assert result.returncode == 1
    assert "Invalid command: invalid" in result.stdout

def run_all_tests():
    tests = [
        test_help,
        test_version,
        test_check,
        test_applist,
        test_invalid_command
    ]
    
    passed = 0
    for test in tests:
        try:
            test()
            passed += 1
        except AssertionError as e:
            print(f"FAILED: {test.__name__}")
    
    print(f"\nSummary: {passed}/{len(tests)} tests passed.")
    if passed != len(tests):
        sys.exit(1)

if __name__ == '__main__':
    run_all_tests()
