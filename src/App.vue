<template>
  <div id="app" class="container-fluid">
    <h1>お気に入り</h1>
    <select class="form-control" style="margin-bottom:1em" v-on:change="changeKey">
      <option v-for='option in selecttags' v-bind:value="option.value" v-bind:key="option.id">
        {{ option.key }}
      </option>
    </select>
    <div v-if="favos.length == 0">
      <div class="loader">Loading...</div>
    </div>
    <div class="card" style="margin-bottom:1em;" v-for='(favo,i) in favos' v-bind:key="favo.id">
      <div class="form-row align-items-center card-body">
        <div class="col-auto" style="max-width:7em;">
          <select class="form-control" v-on:change="changeTag($event,i)" v-model="selectTag[i]">
            <option v-for='option in inputtags' v-bind:value="option.value" v-bind:key="option.id">
              {{ option.key }}
            </option>
          </select>
        </div>
        <div class="col-auto">
          <input class="form-control" style="max-width:6em;" type="text" v-model="newTag[i]" />
        </div>
        <div class="col-auto">
          <button class="btn btn-primary" v-on:click="updateTag(favo.id_str,i)">Set</button>
        </div>
      </div>
      <div class="card-body">
        <p class="card-text">{{favo.body.text}}</p>
        <p class="card-text text-muted">{{ new Date( favo.created_at * 1000 ).toLocaleString('ja-JP') }}</p>
      </div>
      <span v-if="favo.body.extended_entities">
      <span v-for="media in favo.body.extended_entities.media" v-bind:key="media.id">
        <span v-if="media.type == 'photo'">
          <img class="card-img-top" v-bind:src="media.media_url_https">
        </span>
      </span>
      </span>
      <div class="card-body">
        <a v-bind:href="'https://twitter.com/' + favo.body.user.screen_name + '/status/' + favo.body.id_str" target="_blank">Twitterでみる</a>
      </div>
    </div>
  </div>
</template>

<script>
// import HelloWorld from './components/HelloWorld'
import axios from 'axios'

export default {
  name: 'App',
  data: function () {
    return {
      tags: [],
      favos: [],
      se: '',
      se_old: '',
      newTag: [],
      selectTag: [],
      loading: false
    }
  },
  computed: {
    selecttags: function () {
      var a = []
      a.push({ key: '全て', value: '' })
      a.push({ key: '未登録', value: '::::NULL::::' })      
      for (var i = 0, l = this.tags.length; i < l; i++) {
        a.push({ key: this.tags[i], value: this.tags[i] })
      }
      return a
    },
    inputtags: function () {
      var a = ['']
      for (var i = 0, l = this.tags.length; i < l; i++) {
        a.push({ key: this.tags[i], value: this.tags[i] })
      }
      return a
    }
  },
  watch: {
    se: function () {
      this.getFavo()
    }
  },
  methods: {
    _getOffset: function () {
      var offset = 0
      if (this.se_old !== this.se) {
        offset = 0
      } else {
        offset = this.favos.length
      }
      return offset
    },
    _getQ: function () {
      var se = this.se
      var q = ''
      var offset = this._getOffset()
      if (se) {
        q = '?tag=' + se + '&offset=' + offset
      } else {
        q = '?offset=' + offset
      }
      return q
    },
    _setNow2Old: function () {
      if (this.se_old !== this.se) {
        this.se_old = this.se
      }
    },
    _setOrResetFavos: function () {
      if (this.se_old !== this.se) {
        this.favos.splice(0, this.favos.length)
      }
    },
    getFavo: function () {
      var q = this._getQ()
      if (!this.loading) {
        this.loading = true
        axios
          .get('https://tw.lovesaemi.daemon.asia/getfavo_v2.php' + q)
          .then(response => {
            this.loading = false
            this.newTag = []
            this.selectTag = []
            this._setOrResetFavos()
            this._setNow2Old()
            for (var i = 0, l = response.data.length; i < l; i++) {
              this.favos.push(response.data[i])
            }
            for (var x = 0, y = this.favos.length; x < y; x++) {
              this.newTag.push(this.favos[x].tag)
              this.selectTag.push(this.favos[x].tag)
            }
          })
      }
    },
    changeKey: function (event) {
      this.se_old = this.se
      this.se = event.target.value
    },
    changeTag: function (event, i) {
      this.newTag[i] = ''
      this.selectTag[i] = event.target.value
    },
    updateTag: function (id, i) {
      var tagForUpdate = this.newTag[i]
      if (this.newTag[i] === '') {
        tagForUpdate = this.selectTag[i]
      }
      axios
        .get(
          'https://tw.lovesaemi.daemon.asia/settag.php?id=' +
            id +
            '&tag=' +
            tagForUpdate
        )
        .then(response => {
          axios
            .get('https://tw.lovesaemi.daemon.asia/gettag.php')
            .then(response => {
              this.tags = response.data
              this.newTag[i] = tagForUpdate
              // this.getFavo()
            })
        })
    }
  },
  mounted: function () {
    axios.get('https://tw.lovesaemi.daemon.asia/gettag.php').then(response => {
      this.tags = response.data
    })
    this.getFavo()
    var this_ = this
    window.addEventListener('scroll', function (event) {
      var scrollTop = window.pageYOffset
      var height = Math.max.apply(null, [document.body.clientHeight, document.body.scrollHeight, document.documentElement.scrollHeight, document.documentElement.clientHeight]) - 2000
      if (scrollTop >= height) {
        this_.getFavo()
      }
    })
  }
}
</script>

<style>
#app {
  font-family: "Avenir", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  /*text-align: center;*/
  color: #2c3e50;
  margin-top: 30px;
}
.loader,
.loader:before,
.loader:after {
  background: #aaa;
  -webkit-animation: load1 1s infinite ease-in-out;
  animation: load1 1s infinite ease-in-out;
  width: 1em;
  height: 4em;
}
.loader {
  color: #aaa;
  text-indent: -9999em;
  margin: 88px auto;
  position: relative;
  font-size: 11px;
  -webkit-transform: translateZ(0);
  -ms-transform: translateZ(0);
  transform: translateZ(0);
  -webkit-animation-delay: -0.16s;
  animation-delay: -0.16s;
}
.loader:before,
.loader:after {
  position: absolute;
  top: 0;
  content: '';
}
.loader:before {
  left: -1.5em;
  -webkit-animation-delay: -0.32s;
  animation-delay: -0.32s;
}
.loader:after {
  left: 1.5em;
}
@-webkit-keyframes load1 {
  0%,
  80%,
  100% {
    box-shadow: 0 0;
    height: 4em;
  }
  40% {
    box-shadow: 0 -2em;
    height: 5em;
  }
}
@keyframes load1 {
  0%,
  80%,
  100% {
    box-shadow: 0 0;
    height: 4em;
  }
  40% {
    box-shadow: 0 -2em;
    height: 5em;
  }
}
</style>
