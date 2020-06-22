import React, { Component } from 'react';
import 'antd/dist/antd.css';
import { 
  Row,
  Col,
  Carousel,
  Typography,
  Icon,
  Tooltip,
  Badge
 } from 'antd';
import {connect} from 'react-redux';
import Ranking from '../../components/ranking'
import UserHomeCard from '../../components/userHomeCard'
import StyleLoadingCardUser from '../../components/userHomeCard/styleLoadingCardUser'
import MusicCard from '../../components/musicCard'
import StyleLoadingCard from '../../components/musicCard/styleLoadingCard'
import { getHomeSongs, getHotUsers} from '../../actions/app'

const { Title } = Typography;
const dataset = [
  {
    hash:"QmeZ126KyJwibjZt22kAbB6LcoJ5UwWHCupWfNvvp4vT7D",
    image: "QmbBV9r6N8vYR1SZjFePgnxveRWqEKmksBrLWQVau527WE",
    name: "Fatal Police Shootings in the US",
    tags: ["sport", "history"],
    userUpload:{
      addressEthereum: "0x4b771cDB9702eDa44311CE20984Dc4930d16674C",
      avatar: "Qmdq7uiGfeMJYUGA2ygFKHQac5sRrBFwJyFowePVd7t8pc",
      nickName: "Divergent",
      _id: "5dd9f49c61619708f47e070b",
      view: 0,
      _id: "5ed93e1d34225d437265b648"
    }
  },
  {
    hash:"QmeZ126KyJwibjZt22kAbB6LcoJ5UwWHCupWfNvvp4vT7D",
    image: "QmXhmWYuQ2kik7Qku2zJ4yLCiFbZPhy73xipihnXWRkT47",
    name: "COVID-19 Open Research Dataset Challenge (CORD-19)",
    tags: ["sport", "history"],
    userUpload:{
      addressEthereum: "0x4b771cDB9702eDa44311CE20984Dc4930d16674C",
      avatar: "Qmdq7uiGfeMJYUGA2ygFKHQac5sRrBFwJyFowePVd7t8pc",
      nickName: "Pisces",
      _id: "5dd9f49c61619708f47e070b",
      view: 0,
      _id: "5ed93e1d34225d437265b648"
    }
  },
  {
    hash:"QmeZ126KyJwibjZt22kAbB6LcoJ5UwWHCupWfNvvp4vT7D",
    image: "QmP7c3vCnq5n6A6LBbCXKZ7v4uVKyA4SB4w4LvkNtGTFfP",
    name: "Global Significant Earthquake Database from 2150BC",
    tags: ["sport", "history"],
    userUpload:{
      addressEthereum: "0x4b771cDB9702eDa44311CE20984Dc4930d16674C",
      avatar: "Qmdq7uiGfeMJYUGA2ygFKHQac5sRrBFwJyFowePVd7t8pc",
      nickName: "Keyti Đẹp Trai",
      _id: "5dd9f49c61619708f47e070b",
      view: 0,
      _id: "5ed93e1d34225d437265b648"
    }
  },
  {
    hash:"QmeZ126KyJwibjZt22kAbB6LcoJ5UwWHCupWfNvvp4vT7D",
    image: "QmddmTD5DkrxEgCyTgwxM3gVvfCAuigSUFUJSnF7wXJ7Po",
    name: "Zomato Restaurants Hyderabad",
    tags: ["sport", "history"],
    userUpload:{
      addressEthereum: "0x4b771cDB9702eDa44311CE20984Dc4930d16674C",
      avatar: "Qmdq7uiGfeMJYUGA2ygFKHQac5sRrBFwJyFowePVd7t8pc",
      nickName: "Jean",
      _id: "5dd9f49c61619708f47e070b",
      view: 0,
      _id: "5ed93e1d34225d437265b648"
    }
  },
]

const user = [
  {
    addressEthereum: "0x38F01a252ac6D7D447f84ED6F34Ff7Fe624EFe48",
    avatar: "Qmdq7uiGfeMJYUGA2ygFKHQac5sRrBFwJyFowePVd7t8pc",
    follow: 3,
    isFollowed: false,
    nickName: "Âm Khuyết Thi Thính",
    view: 1672,
    _id: "5dfdcd78228b790018bd5688"
  },
  {
    addressEthereum: "0xE802AfaD1E6BFd96b777e40d211C376bfD51C4a4",
    avatar: "QmVYXgSFLU5d9RFaUaBzmJHSTscUiyMvabzSwQta4fEB5d",
    follow: 3,
    isFollowed: true,
    nickName: "Bích Phương",
    view: 1524,
    _id: "5e12b88f990ce80011767802"
  },
  {
    addressEthereum: "0x16C7E1209AdCf05dFFBCc4ABAc5679a10273d95D",
    avatar: "QmW53USm35eyWaNhU5umM8XzHgGVZMRVnvUMPSqiTcZUJK",
    follow: 1,
    isFollowed: false,
    nickName: "Thu Minh",
    view: 1413,
    _id: "5e12b886990ce80011767801"
  },
  {
    addressEthereum: "0xC8E7cc478a6d1D7F894FE05B464c52b92f2c1DA0",
    avatar: "QmSBJWobSW2buFxYTjwW4P8XhsNJdhF8pxkSD8p4Y5Ndr3",
    follow: 3,
    isFollowed: false,
    nickName: "JACK",
    view: 1374,
    _id: "5dfc576d212a98001823033d"
  }
]

class HomeContent extends Component {
  componentDidMount(){
    this.props.getHomeSongs()
    this.props.getHotUsers()
  }
  render() {
    const {appReducer} = this.props
    return (
    <div>
      <Row gutter={[8, 0]}>
        <Carousel autoplay>
          <div>
            <img style={{width: '100%', height: '400px', objectFit: 'cover'}} alt="Dataset test" src="https://ipfs.jumu.tk/QmTX8PxaY9KPJfddacFS8Fo8zt8bvDuVsJCVsb2yVCVx4o"/>
          </div>
          <div>
            <img style={{width: '100%', height: '400px', objectFit: 'cover'}} alt="Dataset test" src="https://ipfs.jumu.tk/QmSaMmyLr4ckwS4uh8Y55RjjoetkVJKceRW5k68qqwywrL"/>
          </div>
          <div>
            <img style={{width: '100%', height: '400px', objectFit: 'cover'}} alt="Dataset test" src="https://ipfs.jumu.tk/QmVNViTuQAcE7wWGtwctRi8AtTvVgfLGrAD3B8YsB53ttP"/>
          </div>
        </Carousel>
              
      </Row>
    
      <Row gutter={[24, 0]} style={{marginTop: 20}}>
        <Col span={17}>

            <Row gutter={[8, 0]} style={{marginTop: 20}}>
              <Title level={4} type="secondary">THE MOST HEAD DATASET</Title>
            </Row>
            <Row gutter={[8, 0]} type="flex" justify="space-around">
              {/* {appReducer.homeData  ? */}
                {dataset.map((record) => {
                  return <Col key={record._id} span={6} style={{width: 190, marginTop: 20}}><MusicCard songInfo={record}/></Col>
                })}
              {/* //   :
              //   <React.Fragment>
              //     <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
              //     <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
              //     <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
              //     <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
              //     <Icon span={4} type="double-right" onClick={()=> this.props.history.push('/upload')}/>
              //   </React.Fragment>
              // } */}
            </Row>
            <Row gutter={[8, 0]} style={{marginTop: 20}} >
              <Title level={4} type="secondary">DATASET TO HUNT</Title>
            </Row>

            <Row gutter={[8, 0]} type="flex" justify="space-around">
              {/* {appReducer.homeData  ? */}
                {/* {appReducer.homeData.mostNew.map */}
                {dataset.map((record) => {
                  return <Col key={record._id} span={6} style={{width: 190, marginTop: 20}}><MusicCard songInfo={record}/></Col>
                })}
                {/* :
                <React.Fragment>
                  <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Icon span={4} type="double-right" onClick={()=> this.props.history.push('/upload')}/>
                </React.Fragment>
              } */}
            </Row>
            <Row gutter={[8, 0]} style={{marginTop: 20}} >
              <Title level={4} type="secondary">THE HOT SURVEY</Title>
            </Row>

            <Row gutter={[8, 0]} type="flex" justify="space-around">
              {/* {appReducer.homeData  ?
                appReducer.homeData.mostNew */}
                {dataset.map((record) => {
                  return <Col key={record._id} span={6} style={{width: 190, marginTop: 20}}><MusicCard songInfo={record}/></Col>
                })}
                {/* :
                <React.Fragment>
                  <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={5} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Icon span={4} type="double-right" onClick={()=> this.props.history.push('/upload')}/>
                </React.Fragment>
              } */}
            </Row>
            <Row gutter={[8, 0]} style={{marginTop: 20}} >
              <Title level={4} type="secondary">NEW UPLOAD</Title>
            </Row>

            <Row gutter={[8, 0]} type="flex" justify="space-around">
              {/* {appReducer.homeData  ?
                appReducer.homeData.mostNew.*/}
                {dataset.map((record) => { 
                  return <Col key={record._id} span={6} style={{width: 190, marginTop: 20}}><MusicCard songInfo={record}/></Col>
                })}
                {/* :
                <React.Fragment>
                  <Col span={6} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={6} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={6} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                  <Col span={6} style={{ marginTop: 20}}><StyleLoadingCard/></Col>
                </React.Fragment>
              }*/}
            </Row>

            <Row  gutter={[8, 0]} style={{marginTop: 20}}>
              <Title level={4} type="secondary">HOT PROVIDER</Title>
            </Row>

            <Row gutter={[8, 0]} type="flex" justify="space-around">
              {/* {(appReducer.hotUserData) ?
                appReducer.hotUserData */}
                {user.map((record) => {
                  return <Col key={record._id} span={6} style={{width: 180, marginTop: 20}}><UserHomeCard user={record}/></Col>
                })}
                {/* :
                <React.Fragment>
                  <Col span={6} style={{ marginTop: 20}}><StyleLoadingCardUser/></Col>
                  <Col span={6} style={{ marginTop: 20}}><StyleLoadingCardUser/></Col>
                  <Col span={6} style={{ marginTop: 20}}><StyleLoadingCardUser/></Col>
                  <Col span={6} style={{ marginTop: 20}}><StyleLoadingCardUser/></Col>
                </React.Fragment>
              } */}
            </Row>
        </Col>
        <Col span={7}>
          <Ranking/>
        </Col>
      </Row>
    </div>
    )
  }
}      


const mapStateToProps = (state) => ({
  appReducer: state.appReducer,
})

const mapDispatchToProps = (dispatch) => ({
  getHomeSongs: ()=>dispatch(getHomeSongs()),
  getHotUsers: ()=>dispatch(getHotUsers())
})
export default connect(mapStateToProps, mapDispatchToProps)(HomeContent);