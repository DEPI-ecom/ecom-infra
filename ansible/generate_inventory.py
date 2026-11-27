import json
import subprocess
import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
TERRAFORM_DIR = PROJECT_DIR / "terraform"
INVENTORY_FILE = Path(__file__).resolve().parent / "inventory.ini"

REQUIRED_OUTPUTS = (
    "bastion_public_ip",
    "control_plane_private_ip",
    "worker_1_private_ip",
    "worker_2_private_ip",
)


def main() -> int:
    try:
        result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=TERRAFORM_DIR,
            capture_output=True,
            text=True,
            check=True,
        )
    except FileNotFoundError:
        print("Error: terraform is not installed or is not on PATH.", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as error:
        print(error.stderr.strip() or "Error: terraform output failed.", file=sys.stderr)
        return error.returncode

    try:
        outputs = json.loads(result.stdout)
        missing = [name for name in REQUIRED_OUTPUTS if name not in outputs]
        if missing:
            raise ValueError(f"Missing Terraform outputs: {', '.join(missing)}")
        values = {name: outputs[name]["value"] for name in REQUIRED_OUTPUTS}
        if any(not isinstance(value, str) or not value.strip() for value in values.values()):
            raise ValueError("One or more required Terraform outputs are empty or invalid.")
    except (json.JSONDecodeError, KeyError, TypeError, ValueError) as error:
        print(f"Error: could not read Terraform outputs: {error}", file=sys.stderr)
        return 1

    bastion_ip = values["bastion_public_ip"]
    control_plane_ip = values["control_plane_private_ip"]
    worker_1_ip = values["worker_1_private_ip"]
    worker_2_ip = values["worker_2_private_ip"]

    inventory = f"""[bastion]
bastion ansible_host={bastion_ip}

[control_plane]
control-plane ansible_host={control_plane_ip}

[workers]
worker-1 ansible_host={worker_1_ip}
worker-2 ansible_host={worker_2_ip}

[k8s:children]
control_plane
workers

[k8s:vars]
ansible_user=ec2-user
ansible_ssh_common_args='-o ProxyJump=ec2-user@{bastion_ip}'
"""

    INVENTORY_FILE.write_text(inventory, encoding="utf-8")
    print(f"Inventory generated: {INVENTORY_FILE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
