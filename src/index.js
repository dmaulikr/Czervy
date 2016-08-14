import React, { Component } from 'react'
import { 
  AppRegistry,
  View,
  Text,
  TouchableHighlight,
  NativeModules
}                           from 'react-native'

let Render

class App extends Component {

  constructor(props) {
    super(props)

    Render = NativeModules.Render
  }

  render() {
    return (
      <View
        style = {{flex: 1, backgroundColor: 'white'}}>
        <TouchableHighlight
          style = {{height:50, width:100, backgroundColor: 'green', alignSelf: 'center'}}
          onPress = { () => { Render.test_render() } }>
          <Text>State of siege!</Text>
        </TouchableHighlight>
      </View>
    )
  }
}

AppRegistry.registerComponent('Czervy', () => App)