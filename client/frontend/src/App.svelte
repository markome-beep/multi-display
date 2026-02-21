<script lang="ts">
import Displays from './components/Displays.svelte'
import Controls from './components/Controls.svelte'

let progress = $state(40)
let displays = $state([
	"192.168.0.10",
	"192.168.0.11",
	"192.168.0.12",
	"192.168.0.13",
])
</script>

<svelte:window 
	ondragover={(e) => e.preventDefault()} 
    ondrop={(e) => e.preventDefault()} 
/>

<main class="bg-zinc-950 h-screen min-h-fit flex flex-col items-center gap-5 p-5 touch-none">
	<Controls/>
	<Displays {displays}/>
</main>
