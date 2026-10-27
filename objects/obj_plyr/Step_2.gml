/// @description Insert description here
// You can write your code in this editor
if (instance_exists(obj_col_box))
{
	i = instance_nearest(x,y,obj_col_box);
	if(obj_plyr.y > i.y){
		depth = -1;
	}
	if(obj_plyr.y<i.y)
	{
	depth = 1;	
	}

}



