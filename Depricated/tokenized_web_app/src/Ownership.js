import React, { Component } from "react";
import returnContracts from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class Ownership extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.getOwner = async () => {//check user address against contract ownership calls
      const self = this;

      if(this.state.storage === "" || this.state.web3 === null || this.state.storageOwner !== ""){}else{
        console.log("Getting storage owner")
        this.state.storage.methods
          .owner()
          .call({ from: self.state.addr }, function (_error, _result) {
            if (_error) {
              console.log(_error);
            } else {
              self.setState({ storageOwner: _result });

              if (_result === self.state.addr) {
                self.setState({ isStorageOwner: true });
              } else {
                self.setState({ isStorageOwner: false });
              }
            }
          });
        }

        if(this.state.PRUF_APP === "" || this.state.web3 === null || this.state.BPPOwner !== ""){}else{
          console.log("Getting BPP owner")
          this.state.PRUF_APP.methods
            .owner()
            .call({ from: self.state.addr }, function (_error, _result) {
              if (_error) {
                console.log(_error);
              } else {
                self.setState({ BPPOwner: _result });
  
                if (_result === self.state.addr) {
                  self.setState({ isBPPOwner: true });
                } else {
                  self.setState({ isBPPOwner: false });
                }
              }
            });
          }

          if(this.state.PRUF_NP === "" || this.state.web3 === null || this.state.BPNPOwner !== ""){}else{
            console.log("Getting BPNP owner")
            this.state.PRUF_NP.methods
              .owner()
              .call({ from: self.state.addr }, function (_error, _result) {
                if (_error) {
                  console.log(_error);
                } else {
                  self.setState({ BPNPOwner: _result });
    
                  if (_result === self.state.addr) {
                    self.setState({ isBPNPOwner: true });
                  } else {
                    self.setState({ isBPNPOwner: false });
                  }
                }
              });
            }
    };

    this.returnsContract = async () => {//request contracts from returnContracts, which returns an object full of contracts
      const self = this;
      var contracts = await returnContracts(self.state.web3);
      //console.log("RC NR: ", contractArray)

      if(this.state.storage < 1){self.setState({ storage: contracts.storage });}
      if(this.state.PRUF_NP < 1){self.setState({ PRUF_NP: contracts.nonPayable });}
      if(this.state.PRUF_APP < 1){self.setState({ PRUF_APP: contracts.payable });}
    };


    this.acctChanger = async () => {//Handle an address change, update state accordingly
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({ addr: e[0] }));
      });
    };

    //Component state declaration

    this.state = {
      isStorageOwner: undefined,
      isBPPOwner: undefined,
      isBPNPOwner: undefined,
      storageOwner: "",
      BPPOwner: "",
      BPNPOwner: "",
      addr: "",
      error: undefined,
      result: "",
      newOwner: "",
      toggle: false,
      assetClass: "",
      storage: "",
      web3: null,
      PRUF_APP: "",
      isTxfrStorage: false,
      isTxfrBPP: false,
      isTxfrBPNP: false,
      PRUF_NP: "",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));
    document.addEventListener("accountListener", this.acctChanger());
  }

  componentDidUpdate(){//stuff to do when state updates

    if(this.state.web3 !== null && this.state.web3 !== undefined){
      this.returnsContract();
    }

    if (this.state.web3 !== null && this.state.storageOwner < 1){
      for (let i = 0; i < 5; i++) {
        this.getOwner();}
      }

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const handleCheckBox = (e) => {
      let setTo;
      if(e === `Storage`){
        if(this.state.isTxfrStorage === false){
          setTo = true;
        }
        else if(this.state.isTxfrStorage === true){
          setTo = false;
        }
        this.setState({isTxfrStorage: setTo});
        console.log("Setting txfr", e, "to: ", setTo);
      }

      else if(e === `PRUF_APP`){
        if(this.state.isTxfrBPP === false){
          setTo = true;
        }
        else if(this.state.isTxfrBPP === true){
          setTo = false;
        }
        this.setState({isTxfrBPP: setTo});
        console.log("Setting txfr", e, "to: ", setTo);
      }

      else if(e === `PRUF_NP`){
        if(this.state.isTxfrBPNP === false){
          setTo = true;
        }
        else if(this.state.isTxfrBPNP === true){
          setTo = false;
        }
        this.setState({isTxfrBPNP: setTo});
        console.log("Setting txfr", e, "to: ", setTo);
      }
    }

    const toggleRenounce = () => {
      if (this.state.toggle === false) {
        this.setState({ toggle: true });
        alert(
          "You are about to renounce the current storage contract. Proceed with caution."
        );
      } else {
        this.setState({ toggle: false });
      }
    };

    const renounce = () => {
      this.state.storage.methods
        .renounceOwnership()
        .send({ from: this.state.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("Ownership renounced");
          console.log("tx receipt: ", receipt);
        });

      console.log(this.state.txHash);
    };

    const transfer = () => {
      if(this.state.newOwner < 1){return(alert("Can not transfer to zero address"))}

      if(this.state.isTxfrStorage === true){
      this.state.storage.methods
        .transferOwnership(this.state.newOwner)
        .send({ from: this.state.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("Storage ownership Transferred to: ", self.state.newOwner);
          self.setState({isStorageOwner: false})
          console.log("tx receipt: ", receipt);
        });}

        if(this.state.isTxfrBPP === true){
        this.state.PRUF_APP.methods
        .transferOwnership(this.state.newOwner)
        .send({ from: this.state.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("BP app ownership Transferred to: ", self.state.newOwner);
          self.setState({isBPPOwner: false})
          console.log("tx receipt: ", receipt);
        });}

        if(this.state.isTxfrBPNP === true){
        this.state.PRUF_NP.methods
        .transferOwnership(this.state.newOwner)
        .send({ from: this.state.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("BP app (non-payable) ownership Transferred to: ", self.state.newOwner);
          self.setState({isBPNPOwner: false})
          console.log("tx receipt: ", receipt);
        });}

        else{alert("please check boxes corresponding to the contract(s) you'd like to transfer")}

      console.log(this.state.txHash);
    };

    return (
      <div>
        <Form className="OForm">
          {this.state.addr === undefined && (
            <div className="VRresults">
              <h2>WARNING!</h2>
              Injected web3 not connected to form!
            </div>
          )}

          {this.state.addr > 0 && this.state.toggle === false && (
            <div>
              <Form.Group>
                {this.state.isStorageOwner === true && (
                <Form.Check
                className = 'checkBox'
                onChange={(e)=>{handleCheckBox(e.target.id)}}
                id={`Storage`}
                label={`Storage`}
                />)}
                {this.state.isBPPOwner === true && (
                <Form.Check
                className = 'checkBox'
                onChange={(e)=>{handleCheckBox(e.target.id)}}
                id={`PRUF_APP`}
                label={`PRUF_APP`}
                />)}
                {this.state.isBPNPOwner === true && (
                <Form.Check
                className = 'checkBox'
                onChange={(e)=>{handleCheckBox(e.target.id)}}
                id={`PRUF_NP`}
                label={`PRUF_NP`}
                />)}
                </Form.Group>
              <h2 className="Headertext">Manage Ownership</h2>
              <br></br>
              <Form.Group as={Col} controlId="formGridNewOwner">
                <Form.Label className="formFont">New Owner :</Form.Label>
                <Form.Control
                  placeholder="New Owner Address"
                  required
                  onChange={(e) => this.setState({ newOwner: e.target.value })}
                  size="lg"
                />
              </Form.Group>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={transfer}
                  >
                    Transfer
                  </Button>
                </Form.Group>
              </div>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay2"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={toggleRenounce}
                  >
                    Renounce
                  </Button>
                </Form.Group>
              </div>
            </div>
          )}

          {this.state.addr > 0 && this.state.toggle === true && (
            <div>
              <h2 className="Headertext">Renounce Ownership?</h2>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay3"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={renounce}
                  >
                    Confirm
                  </Button>
                </Form.Group>
              </div>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay4"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={toggleRenounce}
                  >
                    Go Back
                  </Button>
                </Form.Group>
              </div>
            </div>
          )}
        </Form>
      </div>
    );
  }
}
export default Ownership;