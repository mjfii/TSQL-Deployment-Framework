# TSQL Script Deployment Framework

These PowerShell (`.ps1`) scripts move through a [nested] directory structure to isolate, separate, and execute complex TSQL scripts (`.sql`).

## Motivation

Deploying scripts numbering in the 5's, 10's, or 100's can be difficult across multiple environments and is always pretty tedious.  Also, it can introduce a bit of room for error if something is missed or executed out of order.  I needed a framework to forward along to a DBA for them to execute for DDL deployment, maintenance, and/or metadata management.

## Prerequisites

The default security level may not allow the execution of the scripts.  In order to bypass this and allow 'local' executions, run the below:

```PowerShell
set-executionpolicy remotesigned
```

Additionally, you will need appropriate privileges on the machine where the script is being executed.

## Installation

No installation is required.  Use the scripts as necessary to deploy any number of TSQL scripts.

## Example

If the scripts are placed in the following folder structure with TSQL in subsequent folders, then the following will be occur:

```
    |-- execute tsql scripts.ps1
    |-- dimensions
        |-- customer.sql
        |-- product.sql
        |-- outrigger
            |-- pricing.sql
            |-- customer_product.sql
    |-- facts
        |-- sales.sql
        |-- inventory.sql
        |-- purchasing.sql
```

1. Each folder in same directory as the `.ps1` file will be iterated through in alphanumeric order.
2. Each TSQL file/script will be executed in alphanumeric order.
3. Each TSQL file/script will be broken down into batches, i.e. a `go` separator, and exectued from the top to bottom.
4. Each sub-folder is executed in a similar fashion.

## Contributors

Michael Flanigan  
email: [mick.flanigan@gmail.com](mick.flanigan@gmail.com)  
twitter: [@mjfii](https://twitter.com/mjfii)  

# Versioning  

0.0.0.9000 - Initial deployment (2017-05-02)