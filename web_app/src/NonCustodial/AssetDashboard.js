import React, { Component, useRef } from "react";
import Button from "react-bootstrap/Button";
import "./../index.css";
import Dropdown from 'react-bootstrap/Dropdown';
import Nav from 'react-bootstrap/Nav'
import DropdownButton from 'react-bootstrap/DropdownButton';
import { Printer, RefreshCw, Grid, X, Save, ChevronRight, CornerUpLeft, Home } from "react-feather";
import { QRCode } from 'react-qrcode-logo';
import Example from '../Test/Print'
import { useReactToPrint } from 'react-to-print';
import { connect } from 'react-redux';
import {setGlobalAddr, setGlobalWeb3} from '../actions'



class AssetDashboard extends React.Component {
  constructor(props) {
    super(props);


    this.updateAssets = setInterval(() => {
      if (this.state.assets !== window.assets && this.state.runWatchDog === true) {
        this.setState({ assets: window.assets })
      }

      if (this.state.hasLoadedAssets !== window.hasLoadedAssets && this.state.runWatchDog === true) {
        this.setState({ hasLoadedAssets: window.hasLoadedAssets })
      }

      if (this.state.hasNoAssets !== window.hasNoAssets && this.state.runWatchDog === true) {
        this.setState({ hasNoAssets: window.hasNoAssets })
      }
    }, 100)

    this.moreInfo = (e) => {
      if (e === "back") { return this.setState({ assetObj: {}, moreInfo: false, printQR: undefined }) }

      if (e.DisplayImage !== undefined && e.DisplayImage !== "") {
        this.setState({ selectedImage: e.DisplayImage })
      }
      else {
        this.setState({ selectedImage: Object.values(e.photo)[0] })
      }
      this.setState({ assetObj: e, moreInfo: true })
      window.printObj = e;
      this.setAC(e.assetClass)
    }

    this.setAC = async (AC) => {
      let acDoesExist;

      if (AC === "0" || AC === undefined) { return alert("Selected AC Cannot be Zero") }
      else {
        if (
          AC.charAt(0) === "0" ||
          AC.charAt(0) === "1" ||
          AC.charAt(0) === "2" ||
          AC.charAt(0) === "3" ||
          AC.charAt(0) === "4" ||
          AC.charAt(0) === "5" ||
          AC.charAt(0) === "6" ||
          AC.charAt(0) === "7" ||
          AC.charAt(0) === "8" ||
          AC.charAt(0) === "9"
        ) {
          acDoesExist = await window.utils.checkForAC("id", AC);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click ok to route to our website for more information.")) {
            window.open('https://www.pruf.io')
          }

          this.setState({ assetClass: AC });
          await window.utils.resolveACFromID(AC)
          await window.utils.getACData("id", AC)

          await this.setState({ ACname: window.assetClassName });
        }

        else {
          acDoesExist = await window.utils.checkForAC("name", AC);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click ok to route to our website for more information.")) {
            window.open('https://www.pruf.io')
          }

          this.setState({ ACname: AC });
          await window.utils.resolveAC(AC);
          await this.setState({ assetClass: window.assetClass });
        }

        return this.setState({ assetClassSelected: true, acData: window.tempACData })
      }
    }



    this.sendPacket = (obj, menu, link) => {
      window.sentPacket = obj
      window.menuChange = menu
      window.location.href = '/#/' + link
    }



    this.state = {
      addr: undefined,
      web3: null,
      APP: "",
      NP: "",
      STOR: "",
      AC_MGR: "",
      ECR_NC: "",
      ECR_MGR: "",
      AC_TKN: "",
      A_TKN: "",
      APP_NC: "",
      NP_NC: "",
      ECR2: "",
      authLevel: "",
      PIP: "",
      RCLR: "",
      showDescription: false,
      descriptionElements: undefined,
      assets: { descriptions: [], ids: [], assetClasses: [], statuses: [], names: [] },
      contractArray: [],
      hasLoadedAssets: false,
    };
  }

  componentDidMount() {
    this.setState({
      addr: window.addr,
      runWatchDog: true,
      assetTokenInfo: {}
    })
  }

  componentDidUpdate() {

    if (this.componentRef !== window.componentRef) {
      window.componentRef = this.componentRef
    }
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {

    const generateAssetInfo = (obj) => {
      let images = Object.values(obj.photo)
      let text = Object.values(obj.text)
      let textNames = Object.keys(obj.text)

        const showImage = (e) => {
          console.log(this.state.selectedImage)
          console.log(e)
          this.setState({ selectedImage: e })
        }

        const openPhotoNT = (url) => {
          const newWindow = window.open(url, '_blank', 'noopener,noreferrer')
          if (newWindow) { newWindow.opener = null }
        }

        const _printQR = async () => {
          if (this.state.printQR === undefined) {
            this.setState({ printQR: true })
          }
          else {
            this.setState({ printQR: undefined })
          }
        }

        // const _printQRFile = async (obj) => {

        // }

        const generateThumbs = () => {
          let component = [];

          for (let i = 0; i < images.length; i++) {
            component.push(
              <button key={"thumb" + String(i)} value={images[i]} className="assetImageSelectorButton" onClick={() => { showImage(images[i]) }}>
                <img title="View Image" src={images[i]} className="imageSelectorImage" />
              </button>
            )
          }

          return component
        }

        const generateTextList = () => {
          let component = [];
          for (let i = 0; i < text.length; i++) {
            component.push(
              <>
                <h4 key={"TextElement" + String(i)} className="card-description-selected">{textNames[i]}: {text[i]}</h4>
                <br />
              </>
            )
          }

          return component
        }

        return (
          <div key="selectedAsset">
            <div>
              <div className="assetDashboardSelected">
                <style type="text/css"> {`
  
              .card {
                width: 100%;
                max-width: 100%;
                height: 50rem;
                max-height: 100%;
                background-color: #005480;
                margin-top: 0.3rem;
                color: white;
                word-break: break-all;
              }

              .btn-selectedImage {
                background-color: #005480;
                color: white;
                height: 4rem;
                margin-top: -20rem;
                margin-left: -0.8rem;
                font-weight: bold;
                font-size: 2.2rem;
                border-radius: 0rem 0rem 0.3rem 0.3rem;
              }

              .btn-QR {
                background-color: #002a40;
                color: white;
                height: 2rem;
                width: 17rem;
                margin-top: auto;
                // margin-left: -0.8rem;
                font-weight: bold;
                font-size: 1rem;
                border-radius: 0rem 0rem 0.3rem 0.3rem;
                justify-content: center;
              }
  
            `}
                </style>
                <div className="card" value="100">
                  <div className="row no-gutters">
                    <div className="assetSelecedInfo">
                      <div className="mediaLinkADS">
                        <a className="mediaLinkContentADS" ><Grid onClick={() => { _printQR() }} /></a>
                      </div>
                      {this.state.printQR && (
                        <div>
                          <div className="QRdisplay">
                            <div className="QR">
                              <QRCode
                                value={obj.idxHash}
                                size="150"
                                fgColor="#002a40"
                                logoWidth="35"
                                logoHeight="46"
                                logoImage="https://pruf.io/assets/images/pruf-u-logo-with-border-323x429.png"
                              />
                            </div>
                          </div>
                          <div className="QRdisplay-footer">
                            <div className="mediaLinkQRdisplay">
                              <a className="mediaLinkQRdisplayContent" ><Save onClick={() => { _printQR() }} /></a>
                              <Example/>
                              <a className="mediaLinkQRdisplayContent" ><X onClick={() => { _printQR() }} /></a>
                            </div>
                          </div>
                        </div>
                      )}
                      <button className="assetImageButtonSelected" onClick={() => { openPhotoNT(this.state.selectedImage) }}>
                        <img title="View Image" src={this.state.selectedImage} className="assetImageSelected" />
                      </button>
                      <p className="card-name-selected">Name: {obj.name}</p>
                      <p className="card-ac-selected">Asset Class: {obj.assetClassName}</p>
                      <p className="card-status-selected">Status: {obj.status}</p>
                      <div className="imageSelector">
                        {generateThumbs()}
                      </div>
                      <div className="cardSelectedIdxForm">
                        <h4 className="card-idx-selected">IDX: {obj.idxHash}</h4>
                      </div>
                      <div className="cardDescription-selected">
                        {generateTextList()}
                      </div>
                    </div>
                    {this.state.moreInfo && (
                      <div className="cardButton2">
                        <div className="cardButton2-content">
                          <CornerUpLeft
                            size={35}
                            onClick={() => { this.moreInfo("back") }}
                          />
                        </div>
                      </div>
                    )}

                  </div>
                </div >
              </div >
            </div>
            <div
              className="assetSelectedRouter"
            >
              <Nav className="headerSelected">
                <li>
                  <Button variant="selectedImage" onClick={() => { this.sendPacket(obj, "NC", "transfer-asset-NC") }}>Transfer</Button>
                </li>
                <li>
                  <Button variant="selectedImage" onClick={() => { this.sendPacket(obj, "NC", "import-asset-NC") }}>Import</Button>
                </li>
                <li>
                  <DropdownButton title="Export" drop="up" variant="selectedImage">
                    <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "export-asset-NC") }}>Export</Dropdown.Item>
                    <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "discard-asset-NC") }}>Discard</Dropdown.Item>
                  </DropdownButton>
                </li>
                <li>
                  <Button variant="selectedImage" onClick={() => { this.sendPacket(obj, "NC", "manage-escrow-NC") }}>Escrow</Button>
                </li>
                <li>
                  <DropdownButton title="Modify" drop="up" variant="selectedImage">
                    <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "modify-record-status-NC") }}>Modify Status</Dropdown.Item>
                    <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "decrement-counter-NC") }}>Decrement Counter</Dropdown.Item>
                    <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "modify-description-NC") }}>Modify Description</Dropdown.Item>
                    <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "add-note-NC") }}>Add Note</Dropdown.Item>
                    <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "force-modify-record-NC") }}>Modify Rightsholder</Dropdown.Item>
                  </DropdownButton>
                </li>
              </Nav>
            </div>
          </div>


        )
      }

      const generateAssetDash = (obj) => {
        if (obj.names.length > 0) {
          let component = [];

          for (let i = 0; i < obj.ids.length; i++) {
            //console.log(i, "Adding: ", window.assets.descriptions[i], "and ", window.assets.ids[i])
            component.push(
              <div key={"asset" + String(i)}>
                <style type="text/css"> {`
  
              .card {
                width: 100%;
                max-width: 100%;
                height: 12rem;
                max-height: 100%;
                background-color: #005480;
                margin-top: 0.3rem;
                color: white;
                word-break: break-all;
              }
  
             `}
                </style>
                <div className="card" >
                  <div className="row no-gutters">
                    <div className="col-auto">
                      <button
                        className="assetImageButton"
                        // value={
                        //   JSON.stringify()}
                        onClick={() => {
                          this.moreInfo({
                            countPair: obj.countPairs[i],
                            idxHash: obj.ids[i],
                            descriptionObj: obj.descriptions[i],
                            DisplayImage: obj.displayImages[i],
                            name: obj.names[i],
                            assetClass: obj.assetClasses[i],
                            assetClassName: obj.assetClassNames[i],
                            status: obj.statuses[i],
                            Description: obj.descriptions[i].text.Description,
                            text: obj.descriptions[i].text,
                            photo: obj.descriptions[i].photo
                          })
                        }}
                      >
                        <img title="View Asset" src={obj.displayImages[i]} className="assetImage" />
                      </button>
                    </div>
                    <div>
                      <p className="card-name">Name: {obj.names[i]}</p>
                      <p className="card-ac">Asset Class: {obj.assetClassNames[i]}</p>
                      <p className="card-status">Status: {obj.statuses[i]}</p>
                      <h4 className="card-idx">IDX: {obj.ids[i]}</h4>
                      <br></br>
                      <div className="cardDescription"><h4 className="card-description">Description: {obj.descriptions[i].text.Description}</h4></div>
                    </div>
                    <div className="cardButton">
                      <div className="cardButton-content">
                        <ChevronRight
                          onClick={() => {
                            this.moreInfo({
                              countPair: obj.countPairs[i],
                              idxHash: obj.ids[i],
                              descriptionObj: obj.descriptions[i],
                              DisplayImage: obj.displayImages[i],
                              name: obj.names[i],
                              assetClass: obj.assetClasses[i],
                              assetClassName: obj.assetClassNames[i],
                              status: obj.statuses[i],
                              description: obj.descriptions[i].text.Description,
                              text: obj.descriptions[i].text,
                              photo: obj.descriptions[i].photo
                            })
                          }}
                          size={35}
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

            );
          }

          return component
        }

        else { return <></> }

      }


      const _refresh = () => {
        window.resetInfo = true;
        window.recount = true;
        this.setState({ moreInfo: false, assets: { descriptions: [], ids: [], assetClasses: [], statuses: [], names: [] } })
      }

      return (

        <div>
          <div>
            <div className="mediaLinkAD-home">
              <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
            </div>
            <h2 className="assetDashboardHeader">My Assets</h2>
            <div className="mediaLinkAD-refresh">
              <a className="mediaLinkContentAD-refresh" ><RefreshCw onClick={() => { _refresh() }} /></a>
            </div>
          </div>
          <div className="assetDashboard">
            {!this.state.hasNoAssets && this.state.hasLoadedAssets && !this.state.moreInfo && (<>{generateAssetDash(this.state.assets)}</>)}
            {!this.state.hasNoAssets && this.state.hasLoadedAssets && this.state.moreInfo && (<>{generateAssetInfo(this.state.assetObj)}</>)}
            {!this.state.hasNoAssets && !this.state.hasLoadedAssets && (<div className="VRText"><h2 className="loading">Loading Assets</h2></div>)}
            {this.state.hasNoAssets && (<div className="VRText"><h2>No Assets Held by User</h2></div>)}
          </div>
          <div className="assetDashboardFooter">
          </div>
        </div >

      );
    }
  }

  
  const mapStateToProps = (state) => {

    return{
      globalAddr: state.globalAddr,
      web3: state.web3
    }
  
  }
  
  const mapDispatchToProps = () => {
    return {
      setGlobalAddr,
      setGlobalWeb3,
    }
  }
  
  
  
  export default connect(mapStateToProps, mapDispatchToProps())(AssetDashboard);
