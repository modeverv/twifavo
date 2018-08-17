<template>
  <div id="app" class="container-fluid">
    <h1>お気に入り</h1>
    <select 
      class="form-control" 
      style="margin-bottom:1em"
      v-on:change="changeKey"
      >
      <option 
        v-for='option in selecttags'
        v-bind:value="option.value"
        >
        {{ option.key }}
      </option>
    </select>

    <div class="card" style="margin-bottom:1em;" v-for='(favo,i) in favos'>
      <div class="form-row align-items-center card-body">
        <div class="col-auto" style="max-width:7em;">
          <select 
            class="form-control" 
            v-on:change="changeTag(event,i)"
            v-model="selectTag[i]"
            >
            <option 
              v-for='option in inputtags'
              v-bind:value="option.value"
              >
              {{ option.key }}
            </option>
          </select>
        </div>
        <div class="col-auto">
          <input 
          class="form-control" 
          style="max-width:6em;"
          type="text"
          v-model="newTag[i]"
          />
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
      <span v-for="media in favo.body.extended_entities.media">
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
//import HelloWorld from './components/HelloWorld'
import axios from "axios";

export default {
  name: "App",
  data: function() {
    return {
      tags: [],
      favos: [],
      se: "",
      newTag: [],
      selectTag: []
    };
  },
  computed: {
    selecttags: function() {
      var a = [];
      a.push({ key: "全て", value: "" });
      for (var i = 0, l = this.tags.length; i < l; i++) {
        a.push({ key: this.tags[i], value: this.tags[i] });
      }
      return a;
    },
    inputtags: function() {
      var a = [];
      for (var i = 0, l = this.tags.length; i < l; i++) {
        a.push({ key: this.tags[i], value: this.tags[i] });
      }
      return a;
    }
  },
  watch: {
    se: function() {
      this.getFavo();
    }
  },
  methods: {
    getFavo: function() {
      var se = this.se;
      var q = "";
      if (se) {
        q = "?tag=" + se;
      }
      axios
        .get("https://tw.lovesaemi.daemon.asia/getfavo.php" + q)
        .then(response => {
          this.newTag = [];
          this.selectTag = [];
          this.favos = response.data;
          for (var i = 0, l = this.favos.length; i < l; i++) {
            this.newTag.push(this.favos[i].tag);
            this.selectTag.push(this.favos[i].tag);
          }
        });
    },
    changeKey: function(event) {
      //alert(8)
      this.se = event.target.value;
    },
    changeTag: function(event, i) {
      this.newTag[i] = "";
      this.selectTag[i] = event.target.value;
    },
    updateTag: function(id, i) {
      var tagForUpdate = this.newTag[i];
      if (this.newTag[i] == "") {
        tagForUpdate = this.selectTag[i];
      }
      axios
        .get(
          "https://tw.lovesaemi.daemon.asia/settag.php?id=" +
            id +
            "&tag=" +
            tagForUpdate
        )
        .then(response => {
          axios
            .get("https://tw.lovesaemi.daemon.asia/gettag.php")
            .then(response => {
              this.tags = response.data;
              this.getFavo();
            });
        });
    }
  },
  mounted: function() {
    axios.get("https://tw.lovesaemi.daemon.asia/gettag.php").then(response => {
      this.tags = response.data;
    });
    this.getFavo();
  }
};
</script>

<style>
#app {
  font-family: "Avenir", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  /*text-align: center;*/
  color: #2c3e50;
  /*  margin-top: 60px;*/
}
</style>
